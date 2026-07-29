#!/usr/bin/env bash
# Fetches the ECB banknote design proposal images (A-J) into <target>/images/<PROPOSAL>/
#
# The images are published by the European Central Bank and are NOT part of this
# repository - this script only downloads them into a local or build directory.
#
# Usage:  bash download.sh [target-dir]      (default: the repository root)
set -uo pipefail

BASE="https://www.ecb.europa.eu/euro/banknotes/future_banknotes/shared/img"
DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-$DIR}"
DENOMS=(5 10 20 50 100 200)
PROPOSALS=(a b c d e f g h i j)

ok=0; fail=0

for p in "${PROPOSALS[@]}"; do
  P=$(echo "$p" | tr '[:lower:]' '[:upper:]')
  mkdir -p "$TARGET/images/$P"
  for side in front back; do
    for d in "${DENOMS[@]}"; do
      src="$BASE/banknote-design-proposal-$p-$d-$side.jpg"
      dst="$TARGET/images/$P/$P-$d-$side.jpg"
      if [ -s "$dst" ]; then ok=$((ok+1)); continue; fi     # already there (or cached)
      if curl -fsSL --retry 3 --retry-delay 2 -o "$dst" "$src"; then
        echo "ok    images/$P/$P-$d-$side.jpg"; ok=$((ok+1))
      else
        echo "FAIL  $src"; rm -f "$dst"; fail=$((fail+1))
      fi
    done
  done
done

echo
echo "Done: $ok images present, $fail failed."
[ "$fail" -gt 0 ] && exit 1
exit 0
