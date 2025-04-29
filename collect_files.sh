#!/bin/bash
INPUT_DIR=$1
OUTPUT_DIR=$2
MAX_DEPTH=""
mkdir -p "$OUTPUT_DIR"
if [[ "$3" == "--max_depth" && -n "$4" ]]; then
  MAX_DEPTH=$4
fi
python3 - <<END
import os
import shutil
import sys

input_dir = "$INPUT_DIR"
output_dir = "$OUTPUT_DIR"
max_depth = $MAX_DEPTH if "$MAX_DEPTH" else None

# Словарь для отслеживания количества копий файлов с одинаковыми именами
file_counter = {}

def relative_depth(root_path, base_path):
    return os.path.relpath(root_path, base_path).count(os.sep)

for root, dirs, files in os.walk(input_dir):
    # Проверка ограничения по глубине
    if max_depth is not None and relative_depth(root, input_dir) >= max_depth:
        # Очищаем dirs, чтобы os.walk не заходил глубже
        dirs.clear()
        continue

    for file in files:
        file_path = os.path.join(root, file)
        base_name, ext = os.path.splitext(file)

        # Проверка на дубликаты
        new_name = file
        if file in file_counter:
            file_counter[file] += 1
            new_name = f"{base_name}{file_counter[file]}{ext}"
        else:
            file_counter[file] = 0  # первая версия без суффикса

        dest_path = os.path.join(output_dir, new_name)
        shutil.copy2(file_path, dest_path)

END