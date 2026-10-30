#!/usr/bin/env bash
# Undo SHA pinning: rewrite "uses: owner/repo@<40-hex-sha> # vX" to "uses: owner/repo@vX".
# Usage: ./reset-demo.sh [workflow-file]   (default: .github/workflows/ci.yml)
set -euo pipefail

file="${1:-.github/workflows/ci.yml}"

[[ -f "$file" ]] || { echo "error: $file not found" >&2; exit 1; }

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Only touches pinned lines that carry a trailing "# <version>" comment.
# No `sed -i` (its syntax differs between BSD and GNU), so write to a temp file and copy back.
sed -E 's|(uses:[[:space:]]*[^@[:space:]]+)@[0-9a-f]{40}[[:space:]]+#[[:space:]]*([^[:space:]]+)[[:space:]]*$|\1@\2|' "$file" > "$tmp"
cat "$tmp" > "$file"

echo "Restored unpinned action refs in $file:"
grep -nE 'uses:' "$file"
