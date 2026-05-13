#!/usr/bin/env bash
set -euo pipefail

# Find duplicate markdown content by SHA1 hash
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# Exclude node_modules, build, .git and vendor folders
find . -type f -name '*.md' -not -path './node_modules/*' -not -path './.git/*' -not -path './build/*' -not -path './vendor/*' -print0 \
  | xargs -0 sha1sum | sort > "$tmp"

dups=$(awk '{print $1}' "$tmp" | uniq -d || true)

if [ -n "$dups" ]; then
  echo "Duplicate markdown files detected:"
  for h in $dups; do
    echo "----"
    grep "$h" "$tmp" | awk '{print $2}'
  done
  exit 1
fi

echo "No duplicate markdown content found."
