#!/usr/bin/env bash
# write-to-vault.sh
# Writes a full session transcript note to the Obsidian vault.
# Usage: echo "<markdown>" | bash write-to-vault.sh <project> <label> <filename>
#
# Arguments:
#   $1 — project name (e.g. emerald-grove-pet-clinic)
#   $2 — label (subfolder under the project, e.g. "clinic_issue_1")
#   $3 — filename to write, e.g. "2026-03-04-transcript.md" (must not contain "/")
#
# Environment:
#   OBSIDIAN_VAULT       — override vault path (optional; default: work vault below)
#   OBSIDIAN_NOTES_ROOT  — override notes root folder (optional; default: 50-notes)

set -euo pipefail

VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/work}"
NOTES_ROOT="${OBSIDIAN_NOTES_ROOT:-50-notes}"
FALLBACK_LOG="${HOME}/.claude/obsidian-errors.log"

# ── Args ──────────────────────────────────────────────────────────────────────

PROJECT="${1:-unknown}"
LABEL="${2:-}"
FILENAME="${3:-}"

# ── Helpers ───────────────────────────────────────────────────────────────────

log_error() {
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] ERROR: $*" >> "$FALLBACK_LOG"
  echo "ERROR: $*" >&2
}

# ── Validate ──────────────────────────────────────────────────────────────────

SUBFOLDER="Transcripts"

if [[ ! -d "$VAULT" ]]; then
  log_error "Vault not found at '$VAULT'. Set OBSIDIAN_VAULT or check the path."
  exit 1
fi

if [[ -z "$PROJECT" || "$PROJECT" == "unknown" ]]; then
  log_error "No project name provided."
  exit 1
fi

if [[ -z "$LABEL" ]]; then
  log_error "No label provided."
  exit 1
fi

if [[ -z "$FILENAME" ]]; then
  log_error "No filename provided."
  exit 1
fi

if [[ "$FILENAME" == *"/"* ]]; then
  log_error "Filename '$FILENAME' must not contain '/'."
  exit 1
fi

# ── Read content from stdin ───────────────────────────────────────────────────

CONTENT="$(cat)"

if [[ -z "$CONTENT" ]]; then
  log_error "No content received on stdin."
  exit 1
fi

# ── Build paths ───────────────────────────────────────────────────────────────

NOTES_DIR="$VAULT/$NOTES_ROOT/$SUBFOLDER"
TARGET_DIR="$NOTES_DIR/$PROJECT/$LABEL"
LINK_PREFIX="$PROJECT/$LABEL"

INDEX_FILE="$NOTES_DIR/_index.md"

mkdir -p "$TARGET_DIR"

# ── Handle existing file ──────────────────────────────────────────────────────

BASE="${FILENAME%.md}"
TARGET_FILE="$TARGET_DIR/$FILENAME"

# If a file of this name already exists, append the time rather than
# overwriting — multiple saves of the same kind on the same day is valid.
if [[ -f "$TARGET_FILE" ]]; then
  TIME="$(date +"%H-%M")"
  FINAL_FILE="$TARGET_DIR/${BASE}-${TIME}.md"
else
  FINAL_FILE="$TARGET_FILE"
fi

# ── Write ─────────────────────────────────────────────────────────────────────

printf '%s\n' "$CONTENT" > "$FINAL_FILE"

# ── Update index ──────────────────────────────────────────────────────────────

if [[ ! -f "$INDEX_FILE" ]]; then
  mkdir -p "$NOTES_DIR"
  cat > "$INDEX_FILE" <<EOF
---
title: ${SUBFOLDER} Index
tags: [claude-code, index]
---

# ${SUBFOLDER}

Auto-maintained index of Claude Code ${SUBFOLDER} notes.

| Date | Project | Label | File |
|------|---------|-------|------|
EOF
fi

# Derive the relative Obsidian wiki link
FINAL_BASENAME="$(basename "$FINAL_FILE" .md)"
DATE_NOW="$(date +"%Y-%m-%d")"
INDEX_ENTRY="| $DATE_NOW | $PROJECT | $LABEL | [[$LINK_PREFIX/$FINAL_BASENAME]] |"

if ! grep -qF "$LINK_PREFIX/$FINAL_BASENAME" "$INDEX_FILE" 2>/dev/null; then
  echo "$INDEX_ENTRY" >> "$INDEX_FILE"
fi

# ── Report ────────────────────────────────────────────────────────────────────

echo "$FINAL_FILE"
