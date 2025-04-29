#!/bin/bash

input_dir=$1
output_dir=$2

mkdir -p "$output_dir"

copy_file(){
    local src=$1
    local dst_dir=$2

    find "$src" -type f | while read file_path; do
        filename=$(basename -- "$file_path")
        dest_file_path="$dst_dir/$filename"
        counter=1

        while [ -f "$dest_file_path" ]; do
            base_name="${filename%.*}"
            extension="${filename##*.}"
            if [[ "$filename" == *.* ]]; then
                dest_file_path="$dst_dir/${base_name}_$counter.$extension"
            else
                dest_file_path="$dst_dir/${base_name}_$counter"
            fi
            ((counter++))
        done

        cp "$file_path" "$dest_file_path"
    done
}

copy_file "$input_dir" "$output_dir"