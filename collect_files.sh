#!/usr/bin/env bash
set -euo pipefail
max_depth=""
if [[ "$1" == "--max_depth" ]]; then
  max_depth="$2"; shift 2
fi
[[ $# -eq 2 ]] || { echo "Usage: $0 [--max_depth N] INPUT_DIR OUTPUT_DIR" >&2; exit 1; }
in=$(realpath "$1")
out=$(realpath "$2")
[[ -d "$in" ]] || { echo "$in is not a directory" >&2; exit 1; }
mkdir -p "$out"

copy() {
  src="$1"
  rel="${src#$in/}"
  base="${rel##*/}"
  if [[ "$rel" == "$base" ]]; then
    dirs=()
  else
    IFS='/' read -r -a dirs <<< "${rel%/*}"
  fi
  if [[ -n "$max_depth" ]]; then
    depth=$(( ${#dirs[@]} + 1 ))
    if (( depth > max_depth )); then
      keep=$(( max_depth - 1 ))
      if (( keep > 0 )); then
        dirs=( "${dirs[@]: -$keep}" )
      else
        dirs=()
      fi
    fi
  fi
  dest_dir="$out"
  for d in "${dirs[@]}"; do dest_dir="$dest_dir/$d"; done
  mkdir -p "$dest_dir"
  dest="$dest_dir/$base"
  if [[ -e "$dest" ]]; then
    name="${base%.*}"
    ext=""
    [[ "$name" != "$base" ]] && ext=".${base##*.}"
    i=1
    while [[ -e "$dest_dir/${name}${i}${ext}" ]]; do ((i++)); done
    dest="$dest_dir/${name}${i}${ext}"
  fi
  cp -p "$src" "$dest"
}
export in out max_depth
export -f copy
find "$in" -type f -print0 | xargs -0 -I{} bash -c 'copy "$0"' {}
