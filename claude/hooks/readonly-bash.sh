#!/usr/bin/env bash
# PreToolUse hook: read-only Bash for the `reviewer` subagent.
# exit 2 + stderr = block; exit 0 = allow. Default-deny; any ambiguity denies.
set -u
set -f # no glob expansion while tokenizing

input=$(cat)
cmd=""
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | python3 -I -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command") or "",end="")' 2>/dev/null)
fi

deny() {
  echo "reviewer is read-only: blocked '${1:-}'. Use Read/Grep/Glob, or allowed read-only git/gh/rg/cat/ls commands." >&2
  exit 2
}

[ -n "$cmd" ] || deny ""

# String validation is not a sandbox: reject every shell metacharacter
# (chaining, pipes, redirects, substitution, escapes, newlines) outright so
# simple whitespace tokenizing below is sound.
case "$cmd" in
  *[';&|<>`$(){}\']* | *$'\n'* | *$'\r'*) deny "${cmd%% *}" ;;
esac

read -ra t <<<"$cmd"
[ "${#t[@]}" -gt 0 ] || deny ""
first=${t[0]}

has_tok() { # has_tok GLOB... : true if any token matches any pattern
  local tok p
  for tok in "${t[@]}"; do
    for p in "$@"; do
      # shellcheck disable=SC2254
      case "$tok" in $p) return 0 ;; esac
    done
  done
  return 1
}

case "$first" in
  ls | cat | head | tail | wc | grep | stat | pwd | realpath | basename | dirname) ;;
  rg)
    has_tok '--pre*' '--pre-glob*' '--hostname-bin*' && deny "$first"
    ;;
  git)
    # Subcommand must be the 2nd token so global options (-c, -C, --exec-path,
    # ...) that can run programs or redirect config are never accepted.
    case "${t[1]:-}" in
      diff | log | show | status | blame | rev-parse | ls-files | merge-base | shortlog | describe | cat-file) ;;
      *) deny "$first" ;;
    esac
    has_tok '--output*' '--ext-diff' '--textconv' '-O*' '--open-files-in-pager*' && deny "$first"
    [ "${t[1]}" = "cat-file" ] && has_tok '--filters' '--textconv' && deny "$first"
    ;;
  gh)
    case "${t[1]:-} ${t[2]:-}" in
      "pr view" | "pr diff" | "pr list" | "pr checks" | "pr status" | "issue view" | "issue list" | "repo view" | "run view" | "run list") ;;
      *) deny "$first" ;;
    esac
    has_tok '--web' '-w' && deny "$first"
    ;;
  *) deny "$first" ;;
esac
exit 0
