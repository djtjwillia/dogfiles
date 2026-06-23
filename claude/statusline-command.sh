#!/bin/sh
# Claude Code statusLine script — POSIX /bin/sh compatible, reads JSON from stdin

input=$(cat)

# Ensure Homebrew jq is found when PATH is minimal (e.g. launched from GUI)
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# ---------------------------------------------------------------------------
# Colors — use printf to get the real ESC byte in POSIX sh
# ---------------------------------------------------------------------------
ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
BLINK="${ESC}[5m"
FG_CYAN="${ESC}[36m"
FG_GREEN="${ESC}[32m"
FG_YELLOW="${ESC}[33m"
FG_MAGENTA="${ESC}[35m"
FG_BLUE="${ESC}[34m"
FG_RED="${ESC}[31m"
FG_GRAY="${ESC}[90m"

# ---------------------------------------------------------------------------
# Parse JSON — single jq call extracts all fields at once
# ---------------------------------------------------------------------------
{ read -r cwd; read -r model; read -r used_pct; read -r ctx_total; read -r session_cost; read -r five_hour_pct; read -r seven_day_pct; } << EOF
$(printf '%s' "$input" | jq -r '
  (.workspace.current_dir // .cwd // ""),
  (.model.display_name // .model.id // ""),
  ((.context_window.used_percentage | numbers | tostring) // ""),
  ((.context_window.context_window_size | numbers | tostring) // ""),
  ((.cost.total_cost_usd | numbers | tostring) // ""),
  ((.rate_limits.five_hour.used_percentage | numbers | tostring) // ""),
  ((.rate_limits.seven_day.used_percentage | numbers | tostring) // "")
')
EOF

# ---------------------------------------------------------------------------
# Current directory — strip ~/git/ prefix if present
# ---------------------------------------------------------------------------
[ -z "$cwd" ] && cwd=$(pwd)
home_git="$HOME/git"
case "$cwd" in
  "$home_git"/*) display_dir="${cwd#"$home_git"/}" ;;
  "$HOME"*)      display_dir="~${cwd#"$HOME"}" ;;
  *)             display_dir="$cwd" ;;
esac

# ---------------------------------------------------------------------------
# Git info — single `git status` call replaces 7 separate git commands
# ---------------------------------------------------------------------------
git_info=""
git_staged=0
git_unstaged=0
git_untracked=0

if git_status=$(git -C "$cwd" status --porcelain=v2 --branch 2>/dev/null); then
  { read -r git_branch; read -r ahead; read -r behind; read -r git_staged; read -r git_unstaged; read -r git_untracked; } << EOF
$(printf '%s' "$git_status" | awk '
  /^# branch.head / { branch = $3 }
  /^# branch.ab /   { a=$3; b=$4; sub(/\+/,"",a); sub(/-/,"",b); ahead=a; behind=b }
  /^[12] /          { xy=$2; if (substr(xy,1,1)!=".") s++; if (substr(xy,2,1)!=".") u++ }
  /^\? /            { t++ }
  END               { print branch; print ahead+0; print behind+0; print s+0; print u+0; print t+0 }
')
EOF

  branch_str="$git_branch"
  [ "$ahead"  -gt 0 ] 2>/dev/null && branch_str="${branch_str} ↑${ahead}"
  [ "$behind" -gt 0 ] 2>/dev/null && branch_str="${branch_str} ↓${behind}"
  git_info="$branch_str"
fi

# ---------------------------------------------------------------------------
# Context window
# ---------------------------------------------------------------------------
if [ -n "$ctx_total" ] && [ "$ctx_total" -gt 0 ] 2>/dev/null; then
  total_k=$(( ctx_total / 1000 ))
  pct=0
  [ -n "$used_pct" ] && pct=$(printf '%.0f' "$used_pct")
  used_k=$(echo "$ctx_total $pct" | awk '{printf "%d", $1 * $2 / 100000}')
  ctx_str="${used_k}k/${total_k}k (${pct}%)"
elif [ -n "$used_pct" ]; then
  ctx_str="$(printf '%.0f' "$used_pct")% used"
else
  ctx_str="0% used"
fi

# ---------------------------------------------------------------------------
# Assemble segments
# ---------------------------------------------------------------------------
seg_dir=$(printf "${BOLD}${FG_CYAN}%s${RESET}" "$display_dir")

seg_model=""
[ -n "$model" ] && seg_model=$(printf "${FG_MAGENTA}%s${RESET}" "$model")

seg_ctx=""
[ -n "$ctx_str" ] && seg_ctx=$(printf "${FG_BLUE}%s${RESET}" "$ctx_str")

seg_git=""
if [ -n "$git_info" ]; then
  seg_git=$(printf "${FG_YELLOW}%s${RESET}" "$git_info")
  if [ "$git_staged" -gt 0 ] || [ "$git_unstaged" -gt 0 ] || [ "$git_untracked" -gt 0 ]; then
    change_str=""
    if [ "$git_staged" -gt 0 ]; then
      change_str=$(printf "${FG_GREEN}+%d staged${RESET}" "$git_staged")
    fi
    if [ "$git_unstaged" -gt 0 ]; then
      [ -n "$change_str" ] && change_str="${change_str} "
      change_str="${change_str}$(printf "${FG_RED}%d unstaged${RESET}" "$git_unstaged")"
    fi
    if [ "$git_untracked" -gt 0 ]; then
      [ -n "$change_str" ] && change_str="${change_str} "
      change_str="${change_str}$(printf "${FG_GRAY}%d untracked${RESET}" "$git_untracked")"
    fi
    seg_git="${seg_git}  ${change_str}"
  fi
else
  seg_git=$(printf "${FG_GRAY}No Repo${RESET}")
fi

seg_cost=""
[ -n "$session_cost" ] && seg_cost=$(printf "${FG_GREEN}\$%.2f session${RESET}" "$session_cost")

seg_5h=""
[ -n "$five_hour_pct" ] && seg_5h=$(printf "${FG_BLUE}5h %.0f%%${RESET}" "$five_hour_pct")

seg_7d=""
[ -n "$seven_day_pct" ] && seg_7d=$(printf "${FG_MAGENTA}7d %.0f%%${RESET}" "$seven_day_pct")

seg_wait=$(printf "${BLINK}${FG_CYAN}>${RESET}")

# ---------------------------------------------------------------------------
# Print — pipe-separated, skip empty segments
# ---------------------------------------------------------------------------
line=""
append() {
  [ -n "$1" ] || return
  [ -n "$line" ] && line="${line}  ${FG_GRAY}|${RESET}  $1" || line="$1"
}

append "$seg_dir"
append "$seg_model"
append "$seg_ctx"
[ -n "$seg_git" ] && line="${line}
${seg_git}"

budget_line=""
budget_append() {
  [ -n "$1" ] || return
  [ -n "$budget_line" ] && budget_line="${budget_line}  ${FG_GRAY}|${RESET}  $1" || budget_line="$1"
}
budget_append "$seg_cost"
budget_append "$seg_5h"
budget_append "$seg_7d"

[ -n "$budget_line" ] && line="${line}
${budget_line}"
line="${line}  ${seg_wait}"

printf '%s\n' "${line}"
