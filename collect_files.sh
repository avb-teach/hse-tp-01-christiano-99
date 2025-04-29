#!/usr/bin/env sh
if [ "$#" -ne 2 ]; then echo "Usage: $0 input_dir output_dir" >&2; exit 1; fi
in="$1"
out="$2"
[ -d "$in" ] || { echo "Input directory does not exist" >&2; exit 1; }
mkdir -p "$out"
find "$in" -type f -print0 | while IFS= read -r -d '' f; do
    fn=$(basename "$f")
    dest="$fn"
    if [ -e "$out/$dest" ]; then
        base="${fn%.*}"
        ext=""
        [ "$base" != "$fn" ] && ext=".${fn##*.}"
        n=1
        while [ -e "$out/${base}${n}${ext}" ]; do
            n=$((n+1))
        done
        dest="${base}${n}${ext}"
    fi
    cp "$f" "$out/$dest"
done
exit 0
