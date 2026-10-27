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

# deny REASON [DETAIL]: explain the real cause, then list what is allowed.
deny() {
  {
    echo "reviewer is read-only: $1${2:+ $2}"
    echo "Allowed: read-only git (diff, log, show, status, blame, rev-parse, ls-files, merge-base, shortlog, describe, cat-file), gh (pr view|diff|list|checks|status, issue view|list, repo view, run view|list), rg, grep, cat, head, tail, ls, wc, stat, pwd, realpath, basename, dirname. One simple command per call; no ; & | < > \$ ( ) { } backticks, backslashes, or newlines."
  } >&2
  exit 2
}

[ -n "$cmd" ] || deny "could not read a command from the hook input"

# String validation is not a sandbox: reject every shell metacharacter
# (chaining, pipes, redirects, substitution, escapes, newlines) outright so
# simple whitespace tokenizing below is sound.
case "$cmd" in
  *[';&|<>`$(){}\']* | *$'\n'* | *$'\r'*)
    deny "compound or redirect syntax is not allowed (found shell metacharacters); run one simple command per call" ;;
esac

read -ra t <<<"$cmd"
[ "${#t[@]}" -gt 0 ] || deny "could not read a command from the hook input"
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

flag_deny() { deny "flag not allowed for $first (it can write files or run programs)"; }

case "$first" in
  ls | cat | head | tail | wc | grep | stat | pwd | realpath | basename | dirname) ;;
  rg)
    has_tok '--pre*' '--pre-glob*' '--hostname-bin*' && flag_deny
    ;;
  git)
    # Subcommand must be the 2nd token so global options (-c, -C, --exec-path,
    # ...) that can run programs or redirect config are never accepted.
    case "${t[1]:-}" in
      diff | log | show | status | blame | rev-parse | ls-files | merge-base | shortlog | describe | cat-file) ;;
      *) deny "git '${t[1]:-}' is not allowed (subcommand must come right after git; no -c/-C global options)" ;;
    esac
    has_tok '--output*' '--ext-diff' '--textconv' '-O*' '--open-files-in-pager*' && flag_deny
    [ "${t[1]}" = "cat-file" ] && has_tok '--filters' '--textconv' && flag_deny
    ;;
  gh)
    case "${t[1]:-} ${t[2]:-}" in
      "pr view" | "pr diff" | "pr list" | "pr checks" | "pr status" | "issue view" | "issue list" | "repo view" | "run view" | "run list") ;;
      *) deny "gh '${t[1]:-} ${t[2]:-}' is not allowed" ;;
    esac
    has_tok '--web' '-w' && flag_deny
    ;;
  *) deny "'$first' is not an allowed read-only command" ;;
esac
exit 0
