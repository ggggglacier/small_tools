#!/bin/bash

one_dir_path="/one/dir/path"
another_dir_path="/another/dir/path"
diff_dir_path="/diff/dir/path"

process_folder() {
  local path1="$1"
  local diff_path="${diff_dir_path}${path1#${one_dir_path}}"
  
  for fullpath in "$path1"/*; do
    local base_name=$(basename "$fullpath")
    if [ -d "$fullpath" ]; then
      local subdir="$another_dir_path${fullpath#${one_dir_path}}"
      if [ -d "$subdir" ]; then
        process_folder "$fullpath"
      else
        echo "Directory $fullpath exists, but $subdir doesn't exist."
      fi
    elif [ -f "$fullpath" ]; then
      local target_file="$another_dir_path${fullpath#${one_dir_path}}"
      if [ -f "$target_file" ]; then
        diff_output=$(diff "$fullpath" "$target_file")
        if [ -n "$diff_output" ]; then
          if [ ! -d "$diff_path" ]; then
            mkdir -p "$diff_path"
          fi
          # Save diff output
          echo "$diff_output" > "$diff_path/${base_name}.diff"
        fi
      else
        echo "File $base_name exists in $path1 but not in $another_dir_path"
        if [ ! -d "$diff_path" ]; then
          mkdir -p "$diff_path"
        fi
        diff "$fullpath" /dev/null > "$diff_path/${base_name}.diff"
      fi
    fi
  done
  
  # Check files and directories present in the another_path but not in the one_path
  for fullpath in "$another_dir_path/${path1#${one_dir_path}}"/*; do
    base_name=$(basename "$fullpath")
    if ! [ -e "$path1/$base_name" ]; then
      echo "$base_name exists in $another_dir_path but not in $path1."
      diff /dev/null "$fullpath" > "$diff_dir_path/${fullpath#${another_dir_path}}.diff"
    fi
  done
}

# 开始处理
process_folder "$one_dir_path"