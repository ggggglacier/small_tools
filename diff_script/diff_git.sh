#!/bin/bash

one_dir_path="/one/dir/path"
another_dir_path="/another/dir/path"
diff_dir_path="/diff/dir/path"

process_folder() {
    local folder_path="$1"
    local other_folder_path="$2"
    
    for item in "${folder_path}"/*; do
        local base_name=$(basename "${item}")
        local other_file_path="${other_folder_path}/${base_name}"
        local diff_folder_identity="${folder_path#${one_dir_path}}"
        local diff_folder_path="${diff_dir_path}${diff_folder_identity}"
        
        if [ -f "${item}" ]; then
            # This is a file, do the diff
            if [ ! -f "${other_file_path}" ]; then
                other_file_path="/dev/null"
            fi

            # Use git diff instead of normal diff
            local diff_output=$(git diff --no-index "${item}" "${other_file_path}")

            if [ -n "${diff_output}" ]; then
                if [ ! -d "${diff_folder_path}" ]; then
                    mkdir -p "${diff_folder_path}"
                fi

                echo "${diff_output}" > "${diff_folder_path}/${base_name}.diff"
                echo "Diff saved to ${diff_folder_path}/${base_name}.diff"
            else
                echo "No differences found for ${base_name}"
            fi
        elif [ -d "${item}" ]; then
            process_folder "${item}" "${other_file_path}"
        fi
    done
}

echo "========================================================"
echo "Generate a git diff of the folder under the target path: "
echo "========================================================"

process_folder "${one_dir_path}" "${another_dir_path}"
process_folder "${another_dir_path}" "${one_dir_path}"