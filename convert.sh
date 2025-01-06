#!/bin/bash

# Check if heif-convert is installed (used to convert .heic files to .jpg)
if ! command -v heif-convert &> /dev/null; then
    echo "Error: heif-convert is not installed."
    echo "Please install it with:"
    echo "    sudo apt update"
    echo "    sudo apt install libheif-examples"
    exit 1
fi

# Check if ffmpeg is installed (used to convert .mov files to .mp4)
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed."
    echo "Please install it with:"
    echo "    sudo apt update"
    echo "    sudo apt install ffmpeg"
    exit 1
fi

# Root directory from where the script is run
ROOT_DIR="$(pwd)"

# Store the file list in a variable
file_list=$(find "$ROOT_DIR" -type f -iname "*.*")

# Find and convert all .<SOMETHING> files to .<something>
# rename all file extensions to lowercase
for file in $file_list; do
    # Get the absolute path of the file
    file="$(realpath "$file")"

    # =============================================================================
    # Get the file path without the extension
    base_name="${file%.*}"
    # Get the extension of the file
    extension="${file##*.}"
    # Convert the extension to lowercase
    new_extension="${extension,,}"

    # =============================================================================
    # Remove all .AAE files
    if [ "$new_extension" == "aae" ]; then
        rm "$file"
        echo "Removed AAE:   $file"
        continue
    fi

    # Remove all files that were edited/duplicated (-regex '.*/[A-Z]{4}E[0-9]{4}.*')
    if [[ "$file" =~ .*/[A-Z]{4}E[0-9]{4}.* ]]; then
        rm "$file"
        echo "Removed E:     $file"
        continue
    fi


    # =============================================================================
    # Rename the file if the extension is different (not lower case)
    if [ "$extension" != "$new_extension" ]; then
        mv "$file" "${base_name}.${new_extension}_renamed"
        mv "${base_name}.${new_extension}_renamed" "${base_name}.${new_extension}"
        echo "Renamed:       $file -> ${base_name}.${new_extension}"
        file="${base_name}.${new_extension}"
    fi

    # Rename .jpg to .jpeg
    if [ "$new_extension" == "jpg" ]; then
        mv "$file" "${base_name}.jpeg"
        echo "Renamed:       $file -> ${base_name}.jpeg"
        file="${base_name}.jpeg"
    fi

    # =============================================================================
    # If the file is a .heic and .heif files, convert it to .jpeg
    if [ "$new_extension" == "heic" ] || [ "$new_extension" == "heif" ]; then
        echo "Processing:    $file"
        yes | heif-convert "$file" "${base_name}.jpeg" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Converted:     $file -> ${base_name}.jpeg"
            rm "$file"
        else
            echo "Failed to convert: $file"
        fi
        continue
    fi

    # =============================================================================
    # If the file is a .mov file, convert it to .mp4
    if [ "$new_extension" == "mov" ]; then
        echo "Processing:    $file"
        yes | ffmpeg -i "$file" -vcodec h264 -acodec aac "${base_name}.mp4" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Converted:     $file -> ${base_name}.mp4"
            rm "$file"
        else
            echo "Failed to convert: $file"
        fi
        continue
    fi
done

echo "Conversion completed."
