#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input_dir output_dir" >&2
    exit 1
fi
in="$1"
out="$2"
[ -d "$in" ] || { echo "Input directory does not exist" >&2; exit 1; }
mkdir -p "$out"
declare -A seen
while IFS= read -r -d '' f; do
    b=$(basename "$f")
    root="${b%.*}"
    ext=""
    if [[ "$b" == *.* && "$root" != "" ]]; then
        ext=".${b##*.}"
    else
        root="$b"
    fi
    n=${seen["$b"]:-0}
    if [ "$n" -eq 0 ] && [ ! -e "$out/$b" ]; then
        target="$b"
    else
        n=$((n+1))
        while [ -e "$out/${root}${n}${ext}" ]; do
            n=$((n+1))
        done
        target="${root}${n}${ext}"
    fi
    seen["$b"]=$n
    cp "$f" "$out/$target"
done < <(find "$in" -type f -print0)
