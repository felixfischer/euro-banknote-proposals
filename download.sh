#!/usr/bin/env bash
# Fetches the ECB banknote design proposal images (A-J) into <target>/images/<PROPOSAL>/
#
# The images are published by the European Central Bank and are NOT part of this
# repository - this script only downloads them into a local or build directory.
#
# Given a target other than the repository root it also assembles a deployable
# site there (index.html + screenshots), which is what the deployment runs:
#
#   bash download.sh                 fetch images into ./images, for local use
#   bash download.sh dist            -> ./dist, ready to upload anywhere
#   SKIP_IMAGES=1 bash download.sh dist    same, but the viewer hotlinks the ECB
#
# Usage:  bash download.sh [target-dir]      (default: the repository root)
set -uo pipefail

BASE="https://www.ecb.europa.eu/euro/banknotes/future_banknotes/shared/img"
DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-$DIR}"
DENOMS=(5 10 20 50 100 200)
PROPOSALS=(a b c d e f g h i j)

mkdir -p "$TARGET" || exit 1
TARGET="$(cd "$TARGET" && pwd)"

# Assembling into a build directory: the viewer and the og:image target have to be
# reachable at the deployed URL, not only in the repo. Skipped when the target IS
# the repo, where copying a file onto itself is all it would do.
if [ "$TARGET" != "$DIR" ]; then
  cp "$DIR/index.html" "$TARGET/index.html"
  cp "$DIR"/screenshot-*.jpg "$TARGET/" 2>/dev/null ||
    echo "warning: no screenshot-*.jpg - social media previews will have no image" >&2
fi

if [ "${SKIP_IMAGES:-0}" = "1" ]; then
  echo "SKIP_IMAGES=1 - not downloading, the viewer will load images from ecb.europa.eu"
  [ "$TARGET" != "$DIR" ] && echo "Build complete: $TARGET"
  exit 0
fi

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
[ "$TARGET" != "$DIR" ] && echo "Build complete: $TARGET"
exit 0
