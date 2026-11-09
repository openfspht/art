#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

readonly SOURCE_DIR="logo"
readonly OUTPUT_DIR="png"
readonly SQUARE_SIZES=(16 32 48 64 128 256 512 1024)
readonly WIDE_WIDTHS=(256 512 1024 2048)
readonly FAVICON_SIZES=(16 32 48 180 192 512)
readonly AVATAR_SIZES=(256 512 1024)
readonly APPLE_ICON_SIZE=180
readonly APPLE_ICON_MARK=116
readonly APPLE_ICON_BACKGROUND="#F5F2EAFF"

if ! command -v rsvg-convert >/dev/null; then
  echo "rsvg-convert not found: brew install librsvg" >&2
  exit 1
fi

export_family() {
  local family=$1
  shift
  mkdir -p "$OUTPUT_DIR/$family"
  for svg in "$SOURCE_DIR/openfsp-$family.svg" "$SOURCE_DIR/openfsp-$family"-*.svg; do
    local name
    name=$(basename "$svg" .svg)
    for width in "$@"; do
      rsvg-convert --width "$width" "$svg" --output "$OUTPUT_DIR/$family/$name-$width.png"
    done
  done
}

rm -rf "$OUTPUT_DIR"
export_family mark "${SQUARE_SIZES[@]}"
export_family logo "${WIDE_WIDTHS[@]}"
export_family wordmark "${WIDE_WIDTHS[@]}"
export_family avatar "${AVATAR_SIZES[@]}"

mkdir -p "$OUTPUT_DIR/favicon"
for size in "${FAVICON_SIZES[@]}"; do
  rsvg-convert --width "$size" "$SOURCE_DIR/favicon.svg" --output "$OUTPUT_DIR/favicon/favicon-$size.png"
done

# iOS fills transparency with black and rounds the corners, so this icon is opaque and padded.
readonly APPLE_ICON_OFFSET=$(( (APPLE_ICON_SIZE - APPLE_ICON_MARK) / 2 ))
rsvg-convert --width "$APPLE_ICON_MARK" --height "$APPLE_ICON_MARK" \
  --page-width "$APPLE_ICON_SIZE" --page-height "$APPLE_ICON_SIZE" \
  --left "$APPLE_ICON_OFFSET" --top "$APPLE_ICON_OFFSET" \
  --background-color "$APPLE_ICON_BACKGROUND" \
  "$SOURCE_DIR/openfsp-mark.svg" --output "$OUTPUT_DIR/favicon/apple-touch-icon.png"

find "$OUTPUT_DIR" -name '*.png' | wc -l | xargs echo "PNG files written:"
