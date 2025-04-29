#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 2 ]] || { echo "Usage: $0 INPUT_DIR OUTPUT_DIR" >&2; exit 1; }

in=$(realpath "$1")
out=$(realpath "$2")

[[ -d "$in" ]] || { echo "$in is not a directory" >&2; exit 1; }
mkdir -p "$out"

copy() {
    src="$1"
    dest="$out/$(basename "$src")"
    if [[ -e "$dest" ]]; then
        name="${dest%.*}"
        ext="${dest##*.}"
        [[ "$dest" == *.* ]] || ext=""
        [[ -n "$ext" ]] && ext=".$ext"
        i=1
        while [[ -e "${name}${i}${ext}" ]]; do
            ((i++))
        done
        dest="${name}${i}${ext}"
    fi
    cp -p "$src" "$dest"
}

export out
export -f copy

find "$in" -type f -print0 | xargs -0 -I{} bash -c 'copy "$0"' {}
