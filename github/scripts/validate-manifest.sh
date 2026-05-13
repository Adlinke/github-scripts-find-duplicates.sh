#!/usr/bin/env bash
set -euo pipefail

MANIFEST="examples/manifest.json"
ALLOWED_HOSTS=("codesandbox.io" "jsfiddle.net" "dabblet.com" "your-self-hosted-domain.example")

if [ ! -f "$MANIFEST" ]; then
  echo "No examples/manifest.json found; skipping manifest validation."
  exit 0
fi

# Basic JSON validation
jq -e . "$MANIFEST" >/dev/null || { echo "examples/manifest.json is not valid JSON"; exit 1; }

# Validate entries
errors=0
len=$(jq 'length' "$MANIFEST")
for i in $(seq 0 $((len - 1))); do
  id=$(jq -r ".[$i].id // empty" "$MANIFEST")
  title=$(jq -r ".[$i].title // empty" "$MANIFEST")
  url=$(jq -r ".[$i].canonical_url // empty" "$MANIFEST")

  if [ -z "$id" ] || [ -z "$title" ] || [ -z "$url" ]; then
    echo "Manifest entry $i missing required fields (id,title,canonical_url)"
    errors=$((errors+1))
    continue
  fi

  host=$(echo "$url" | awk -F/ '{print $3}')
  ok=0
  for h in "${ALLOWED_HOSTS[@]}"; do
    if [[ "$host" == *"$h" ]]; then ok=1; break; fi
  done
  if [ $ok -ne 1 ]; then
    echo "Manifest entry $id uses disallowed host: $host"
    errors=$((errors+1))
  fi
done

if [ $errors -ne 0 ]; then
  echo "Manifest validation failed with $errors error(s)."
  exit 1
fi

echo "Manifest validation passed."
