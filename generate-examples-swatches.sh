#!/usr/bin/env bash
# Regenerate the digit swatches (swatch-0.png..swatch-9.png, swatch-a.png,
# swatch-b.png, plus the white hour swatch swatch-0h.png labeled 12)
# and the example tricolor images (example-*.png) from the
# color palette defined in all-times.tex, so the palette has one source
# of truth.
#
# Requires ImageMagick (`magick`).

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

TEX_FILE="all-times.tex"
FONT="/System/Library/Fonts/Supplemental/Verdana Bold.ttf"
POINTSIZE=243
# Examples are 1200x800 landscape flags (3:2), built from three vertical stripes.
# Swatches use the same 800px height and a 1:2 width-to-height ratio.
SWATCH_SIZE=400x800
BAND_SIZE=400x800

# digit index -> filename stem (10/11 use the hex-clock convention a/b)
stem_for() {
  case "$1" in
    10) echo "a" ;;
    11) echo "b" ;;
    *)  echo "$1" ;;
  esac
}

# example filename char -> digit index (inverse of stem_for)
digit_for() {
  case "$1" in
    a) echo "10" ;;
    b) echo "11" ;;
    *) echo "$1" ;;
  esac
}

declare -A HEX_OF

echo "== swatches =="
while IFS= read -r line; do
  n=$(sed -E 's/\\definecolor\{([0-9]+)\}.*/\1/' <<<"$line")
  hex=$(sed -E 's/.*\{HTML\}\{([0-9A-Fa-f]{6})\}.*/\1/' <<<"$line")
  HEX_OF[$n]="$hex"
  stem=$(stem_for "$n")
  out="swatch-${stem}.png"
  # the label drawn on the swatch is the decimal digit index itself
  # (so 10/11 render as "10"/"11", even though the files are a.png/b.png)
  label="$n"

  # every swatch uses white text, except light backgrounds (e.g. the
  # white "0" swatch) where white text would be invisible
  r=$((16#${hex:0:2})); g=$((16#${hex:2:2})); b=$((16#${hex:4:2}))
  luminance=$(( (299*r + 587*g + 114*b) / 1000 ))
  if [ "$luminance" -gt 130 ]; then
    textcolor="black"
  else
    textcolor="white"
  fi

  border=()
  if [[ "$n" == "0" ]]; then
    border=(-stroke black -strokewidth 2 -fill none -draw "rectangle 1,1 398,798")
  fi
  magick -size "$SWATCH_SIZE" "xc:#${hex}" \
    -font "$FONT" -pointsize "$POINTSIZE" \
    -fill "$textcolor" -gravity center -annotate +0-2 "$label" \
    "${border[@]}" "$out"

  echo "wrote $out  (#$hex, $textcolor text)"
done < <(grep '\\definecolor' "$TEX_FILE")

# Hour-display variant of zero, labeled 12.
magick -size "$SWATCH_SIZE" xc:white \
  -font "$FONT" -pointsize "$POINTSIZE" \
  -fill black -gravity center -annotate +0-2 "12" \
  -stroke black -strokewidth 2 -fill none -draw "rectangle 1,1 398,798" \
  "swatch-0h.png"
echo "wrote swatch-0h.png  (#FFFFFF, black text)"

echo "== examples =="
for out in example-147.png example-503.png example-305.png example-359.png example-037.png example-629.png example-a51.png; do
  digits=$(sed -E 's/example-([0-9a-b]{3})\.png/\1/' <<<"$out")
  bands=()
  for (( i=0; i<3; i++ )); do
    ch="${digits:$i:1}"
    n=$(digit_for "$ch")
    hex="${HEX_OF[$n]}"
    band="/tmp/$$-band-$i.png"
    if [[ "$n" == "0" ]]; then
      magick -size "$BAND_SIZE" "xc:#${hex}" \
        -stroke black -strokewidth 2 -fill none -draw "rectangle 1,1 398,798" "$band"
    else
      magick -size "$BAND_SIZE" "xc:#${hex}" "$band"
    fi
    bands+=("$band")
  done
  magick "${bands[@]}" +append "$out"
  rm -f "${bands[@]}"
  echo "wrote $out  (digits $digits)"
done
