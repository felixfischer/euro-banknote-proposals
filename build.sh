#!/usr/bin/env bash
# Assembles the deployable site in ./dist:
#   dist/index.html    the viewer
#   dist/screenshot.jpg  social-media preview image referenced by the og:image tag
#   dist/images/...    the banknote images, fetched from ecb.europa.eu at build time
#
# Set SKIP_IMAGES=1 to build without them; the viewer then loads every image
# straight from ecb.europa.eu at runtime.
#
# Usage:  bash build.sh [output-dir]         (default: ./dist)
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="${1:-$DIR/dist}"

mkdir -p "$OUT"
cp "$DIR/index.html" "$OUT/index.html"

# The og:image target must be reachable at the deployed URL, not only in the repo.
if [ -f "$DIR/screenshot.jpg" ]; then
  cp "$DIR/screenshot.jpg" "$OUT/screenshot.jpg"
else
  echo "warning: screenshot.jpg missing - social media previews will have no image" >&2
fi

if [ "${SKIP_IMAGES:-0}" = "1" ]; then
  echo "SKIP_IMAGES=1 - not downloading, the viewer will load images from ecb.europa.eu"
else
  # Existing files are kept, so a cached images/ directory makes rebuilds instant.
  bash "$DIR/download.sh" "$OUT"
fi

echo "Build complete: $OUT"
