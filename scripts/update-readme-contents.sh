#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
README_FILE="$ROOT_DIR/README.md"
START_MARKER="<!-- papers:start -->"
END_MARKER="<!-- papers:end -->"

if [[ ! -f "$README_FILE" ]]; then
  echo "README.md was not found at the repository root."
  exit 1
fi

mapfile -t PAPER_FILES < <(
  cd "$ROOT_DIR"
  find . -type f -name "*.md" \
    ! -path "./.git/*" \
    ! -path "./.github/*" \
    ! -name "README.md" \
    | sed "s|^\./||" \
    | sort
)

if [[ "${#PAPER_FILES[@]}" -eq 0 ]]; then
  CONTENTS_BLOCK="_No papers yet._"
else
  CONTENTS_BLOCK=""
  for file in "${PAPER_FILES[@]}"; do
    title="$(basename "$file" .md)"
    title="${title//-/ }"
    title="${title//_/ }"
    CONTENTS_BLOCK+="- [${title}](${file})"$'\n'
  done
  CONTENTS_BLOCK="${CONTENTS_BLOCK%$'\n'}"
fi

TMP_FILE="$(mktemp)"

if grep -qF "$START_MARKER" "$README_FILE" && grep -qF "$END_MARKER" "$README_FILE"; then
  awk -v start="$START_MARKER" -v end="$END_MARKER" -v block="$CONTENTS_BLOCK" '
    $0 == start {
      print
      print block
      in_block = 1
      next
    }
    $0 == end {
      in_block = 0
      print
      next
    }
    !in_block {
      print
    }
  ' "$README_FILE" > "$TMP_FILE"
else
  cat "$README_FILE" > "$TMP_FILE"
  {
    echo
    echo "## Contents"
    echo "$START_MARKER"
    echo "$CONTENTS_BLOCK"
    echo "$END_MARKER"
  } >> "$TMP_FILE"
fi

mv "$TMP_FILE" "$README_FILE"
echo "Updated README contents list."
