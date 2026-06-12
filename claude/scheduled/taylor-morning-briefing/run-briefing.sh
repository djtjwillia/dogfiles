#!/usr/bin/env bash
# =============================================================================
# Daily Morning Briefing — run-briefing.sh
# Triggered by launchd at 7:30 AM local time.
# Reads the SKILL.md from ~/Claude/Scheduled/, injects today's date and Slack
# oldest timestamp, then invokes claude with a narrow allowlist.
# Output is persisted to ~/Claude/briefing-output/briefing-YYYY-MM-DD.md.
# =============================================================================

set -uo pipefail

DATE="$(date +%Y-%m-%d)"
OLDEST="$(python3 -c 'import time; print(int(time.time() - 18*3600))')"
OUTPUT_DIR="$HOME/Claude/briefing-output"
LOG_DIR="$OUTPUT_DIR/.logs"
OUTPUT_FILE="$OUTPUT_DIR/briefing-${DATE}.md"
LOG_FILE="$LOG_DIR/run-${DATE}.log"
SKILL_FILE="$HOME/Claude/Scheduled/taylor-morning-briefing/SKILL.md"

# Locate the claude CLI (handles Homebrew on Apple Silicon vs Intel)
CLAUDE_BIN="$(which claude 2>/dev/null \
  || ls /usr/local/bin/claude /opt/homebrew/bin/claude 2>/dev/null | head -1 \
  || echo '')"

# ---------------------------------------------------------------------------
mkdir -p "$OUTPUT_DIR" "$LOG_DIR"
exec >> "$LOG_FILE" 2>&1   # all output from here goes to the log
echo "[$(date)] Starting daily briefing for $DATE"

# Guard: claude CLI must exist
if [[ -z "$CLAUDE_BIN" || ! -x "$CLAUDE_BIN" ]]; then
  echo "[$(date)] ERROR: claude CLI not found. Install it from https://claude.ai/download"
  osascript -e 'display notification "claude CLI not found — briefing skipped" with title "Daily Briefing" subtitle "Error"' 2>/dev/null || true
  exit 1
fi

# Guard: skip if briefing already exists for today
if [[ -s "$OUTPUT_FILE" ]]; then
  echo "[$(date)] Briefing already exists for $DATE, skipping."
  exit 0
fi

# Guard: skill file must exist
if [[ ! -f "$SKILL_FILE" ]]; then
  echo "[$(date)] ERROR: SKILL.md not found at $SKILL_FILE"
  osascript -e 'display notification "SKILL.md missing — briefing skipped" with title "Daily Briefing" subtitle "Error"' 2>/dev/null || true
  exit 1
fi

# ---------------------------------------------------------------------------
# Build the prompt: inject date/oldest header, then the skill body (frontmatter stripped)
# ---------------------------------------------------------------------------
SKILL_BODY="$(awk '/^---/{n++; if(n==2){found=1; next}} found{print}' "$SKILL_FILE")"

PROMPT="Today's date is ${DATE}.
The Slack oldest unix timestamp (18 hours ago) is ${OLDEST}.
Use these values wherever the skill instructs you to use today's date or compute the oldest timestamp.

${SKILL_BODY}"

# ---------------------------------------------------------------------------
# Run claude and capture output
# ---------------------------------------------------------------------------
echo "[$(date)] Running: $CLAUDE_BIN -p ..."

ALLOWLIST="mcp__claude_ai_Slack__slack_read_channel,mcp__claude_ai_Slack__slack_read_thread,mcp__claude_ai_Slack__slack_search_public,mcp__claude_ai_Slack__slack_search_users,mcp__claude_ai_Slack__slack_read_user_profile,mcp__claude_ai_Slack__slack_send_message,mcp__claude_ai_Google_Calendar__list_calendars,mcp__claude_ai_Google_Calendar__list_events,mcp__claude_ai_Google_Calendar__get_event,WebSearch"

"$CLAUDE_BIN" -p "$PROMPT" \
  --output-format text \
  --allowedTools "$ALLOWLIST" \
  > "$OUTPUT_FILE"

EXIT_CODE=$?

# ---------------------------------------------------------------------------
# Notify and validate
# ---------------------------------------------------------------------------
if [[ $EXIT_CODE -eq 0 && -s "$OUTPUT_FILE" ]]; then
  echo "[$(date)] SUCCESS: Briefing saved to $OUTPUT_FILE"
  osascript -e "display notification \"Saved to ~/Claude/briefing-output/\" with title \"Daily Briefing Ready\" subtitle \"$DATE\"" 2>/dev/null || true
else
  echo "[$(date)] ERROR: claude exited with code $EXIT_CODE or produced empty output."
  # Clean up empty file to allow retry
  [[ -f "$OUTPUT_FILE" ]] && rm -f "$OUTPUT_FILE"
  osascript -e "display notification \"Check .logs/run-${DATE}.log for details\" with title \"Daily Briefing Failed\" subtitle \"$DATE\"" 2>/dev/null || true
  exit 1
fi
