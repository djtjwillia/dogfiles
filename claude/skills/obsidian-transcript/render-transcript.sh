#!/usr/bin/env bash
# render-transcript.sh
# Renders a Claude Code session JSONL transcript to Obsidian-flavoured markdown on stdout.
#
# Usage: render-transcript.sh <session.jsonl>
#
# Only .type=="user" and .type=="assistant" records are considered; everything
# else (attachment, system, queue-operation, mode, etc.) is ignored. Tool
# results and extended thinking are never rendered — the transcript is always
# just user prompts, assistant prose, and one-line `> 🔧` tool-call markers.

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "render-transcript.sh: jq is required but not found on PATH." >&2
  exit 1
fi

SESSION_FILE="${1:-}"
if [[ -z "$SESSION_FILE" ]]; then
  echo "Usage: render-transcript.sh <session.jsonl>" >&2
  exit 1
fi

if [[ ! -f "$SESSION_FILE" ]]; then
  echo "render-transcript.sh: session file '$SESSION_FILE' not found." >&2
  exit 1
fi

# Convert an ISO-8601 UTC timestamp to local HH:MM.
to_local_hhmm() {
  local ts="$1"
  # Strip fractional seconds if present (date -j needs a fixed format).
  local clean="${ts%%.*}"
  clean="${clean%Z}Z"
  local epoch
  epoch="$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%SZ" "$clean" "+%s" 2>/dev/null)" || {
    echo "??:??"
    return
  }
  date -j -r "$epoch" "+%H:%M" 2>/dev/null || echo "??:??"
}

# Extract the (first, DOTALL) contents of <tag>...</tag> from text; empty if absent.
extract_tag() {
  local text="$1" tag="$2"
  printf '%s' "$text" | perl -0777 -ne "print \$1 if /<${tag}>(.*?)<\/${tag}>/s" 2>/dev/null
}

# Harness-injected tags whose entire block (including content) is never part
# of what the human or the assistant actually said, and so must never render
# as if they typed it. Add future tags here — one line each.
HARNESS_STRIP_TAGS=(
  system-reminder
  task-notification
)

# Strip every <tag>...</tag> block for each tag in HARNESS_STRIP_TAGS
# (multiline/DOTALL, non-greedy).
strip_harness_tags() {
  local text="$1" tag
  for tag in "${HARNESS_STRIP_TAGS[@]}"; do
    text="$(printf '%s' "$text" | perl -0pe "s/<${tag}>.*?<\/${tag}>//gs" 2>/dev/null || printf '%s' "$text")"
  done
  printf '%s' "$text"
}

FIRST_TURN="true"

emit_separator() {
  if [[ "$FIRST_TURN" == "false" ]]; then
    echo
    echo "---"
    echo
  fi
  FIRST_TURN="false"
}

# ── Render a single user record ─────────────────────────────────────────────

render_user() {
  local record="$1"
  local ts hhmm content_type body
  ts="$(jq -r '.timestamp // empty' <<<"$record")"
  hhmm="??:??"
  [[ -n "$ts" ]] && hhmm="$(to_local_hhmm "$ts")"

  content_type="$(jq -r '.message.content | type' <<<"$record")"

  local rendered=""

  if [[ "$content_type" == "string" ]]; then
    local raw stripped
    raw="$(jq -r '.message.content' <<<"$record")"
    stripped="$(strip_harness_tags "$raw")"
    stripped="$(printf '%s' "$stripped" | sed -e '/./,$!d')"

    # Slash-command form: <command-message>X</command-message><command-name>/X</command-name>[<command-args>...</command-args>]
    if grep -q '<command-name>' <<<"$stripped"; then
      local cmd_name cmd_args
      cmd_name="$(extract_tag "$stripped" "command-name")"
      cmd_args="$(extract_tag "$stripped" "command-args")"
      rendered="$cmd_name"
      [[ -n "$cmd_args" ]] && rendered="$rendered $cmd_args"
    elif grep -q '<bash-input>' <<<"$stripped"; then
      local bash_cmd bash_out bash_err
      bash_cmd="$(extract_tag "$stripped" "bash-input")"
      bash_out="$(extract_tag "$stripped" "bash-stdout")"
      bash_err="$(extract_tag "$stripped" "bash-stderr")"
      rendered="\`\`\`bash
\$ ${bash_cmd}"
      [[ -n "$bash_out" ]] && rendered="${rendered}
${bash_out}"
      [[ -n "$bash_err" ]] && rendered="${rendered}
${bash_err}"
      rendered="${rendered}
\`\`\`"
    else
      rendered="$stripped"
    fi
  else
    # Array content: concatenate text blocks; tool_result blocks are always skipped.
    local parts=()
    local n
    n="$(jq '.message.content | length' <<<"$record")"
    local i
    for ((i = 0; i < n; i++)); do
      local block_type
      block_type="$(jq -r ".message.content[$i].type" <<<"$record")"
      if [[ "$block_type" == "text" ]]; then
        local raw stripped
        raw="$(jq -r ".message.content[$i].text" <<<"$record")"
        stripped="$(strip_harness_tags "$raw")"
        [[ -n "$(printf '%s' "$stripped" | tr -d '[:space:]')" ]] && parts+=("$stripped")
      fi
    done
    if [[ ${#parts[@]} -gt 0 ]]; then
      rendered="$(printf '%s\n\n' "${parts[@]}")"
      rendered="${rendered%$'\n\n'}"
    fi
  fi

  # Skip entirely if nothing remains after stripping/trimming.
  if [[ -z "$(printf '%s' "$rendered" | tr -d '[:space:]')" ]]; then
    return 1
  fi

  # Only a user record that actually emits output ends the current assistant
  # turn; tool_result-only carriers (already filtered out above) must not
  # split consecutive assistant records into separate headings.
  flush_assistant
  emit_separator
  echo "## 🧑 User — ${hhmm}"
  echo
  printf '%s\n' "$rendered"
  return 0
}

# ── Render one or more merged assistant records ─────────────────────────────

render_assistant_group() {
  local -a records=("$@")
  local ts hhmm
  ts="$(jq -r '.timestamp // empty' <<<"${records[0]}")"
  hhmm="??:??"
  [[ -n "$ts" ]] && hhmm="$(to_local_hhmm "$ts")"

  local body=""
  # Tracks the kind of the last emitted line ("text" or "tool_use") so a
  # transition between a `> 🔧` tool-use block and prose gets a blank-line
  # separator — otherwise markdown treats the prose as a lazy continuation
  # of the blockquote. Consecutive tool_use lines intentionally stay adjacent.
  local last_kind=""
  local rec
  for rec in "${records[@]}"; do
    local n
    n="$(jq '.message.content | length' <<<"$rec")"
    local i
    for ((i = 0; i < n; i++)); do
      local block_type
      block_type="$(jq -r ".message.content[$i].type" <<<"$rec")"
      case "$block_type" in
        text)
          local text
          text="$(jq -r ".message.content[$i].text" <<<"$rec")"
          if [[ -n "$(printf '%s' "$text" | tr -d '[:space:]')" ]]; then
            [[ "$last_kind" == "tool_use" ]] && body="${body}
"
            body="${body}${text}

"
            last_kind="text"
          fi
          ;;
        thinking)
          : # extended thinking is never rendered
          ;;
        tool_use)
          local name desc
          name="$(jq -r ".message.content[$i].name" <<<"$rec")"
          desc="$(jq -r ".message.content[$i].input.description // empty" <<<"$rec")"
          if [[ -z "$desc" ]]; then
            desc="$(jq -r ".message.content[$i].input.command // .message.content[$i].input.file_path // .message.content[$i].input.prompt // empty" <<<"$rec")"
            desc="$(printf '%s' "$desc" | tr '\n' ' ')"
            desc="${desc:0:100}"
          fi
          if [[ -n "$desc" ]]; then
            # No extra separator needed for text -> tool_use: text blocks
            # already end with a trailing blank line.
            body="${body}> 🔧 \`${name}\`: ${desc}
"
            last_kind="tool_use"
          fi
          ;;
      esac
    done
  done

  # Trim trailing blank lines.
  body="$(printf '%s' "$body" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')"

  if [[ -z "$(printf '%s' "$body" | tr -d '[:space:]')" ]]; then
    return 1
  fi

  emit_separator
  echo "## 🤖 Assistant — ${hhmm}"
  echo
  printf '%s\n' "$body"
  return 0
}

# ── Main loop: walk records, merging consecutive assistant turns ───────────

pending_assistant=()

flush_assistant() {
  if [[ ${#pending_assistant[@]} -gt 0 ]]; then
    render_assistant_group "${pending_assistant[@]}" || true
    pending_assistant=()
  fi
}

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  rtype="$(jq -r '.type // empty' <<<"$line" 2>/dev/null || echo "")"
  case "$rtype" in
    user)
      render_user "$line" || true
      ;;
    assistant)
      pending_assistant+=("$line")
      ;;
    *)
      : # ignore all other record types
      ;;
  esac
done < "$SESSION_FILE"

flush_assistant
