#!/bin/bash

# This script converts all media files in the current directory and its subdirectories to the .mp4 format, and gives the user an option for what to do with the original files, with a progress prompt.

# Make sure ffmpeg is installed
if ! [ -x "$(command -v ffmpeg)" ]; then
    echo 'Error: ffmpeg is not installed.' >&2
    exit 1
fi

# Get the current directory
dir=`pwd`

# Find all media files in the current directory and its subdirectories
find "$dir" -type f \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.flv' -o -iname '*.wmv' -o -iname '*.mov' \) -print0 | while IFS= read -r -d '' file; do
  filename=$(basename "$file")
  # Prompt the user for what to do with the original files
echo "What would you like to do with the original files?"
select option in "Move to backup folder" "Delete" "Leave as is"
do
    case $option in
        "Move to backup folder")
            # Create a backup folder
            echo "Where would you like to create the backup folder?"
            select location in "Original directory" "Custom location"
            do
                case $location in
                    "Original directory")
                        # Create a backup folder
                        mkdir -p "$dir/backup"
                        ffmpeg -i "$file" -c:v libx264 -c:a aac -strict experimental -b:a 128k -b:v 1200k -r 30 -progress pipe:1 "${file%.*}.mp4"
                        mv "$file" "$dir/backup/"
                        echo "Conversion and backup complete!"
                        break
                        ;;
                    "Custom location")
                        echo "Please enter the custom location path:"
                        read custom_location
                        mkdir -p "$custom_location"
                        ffmpeg -i "$file" -c:v libx264 -c:a aac -strict experimental -b:a 128k -b:v 1200k -r 30 -progress pipe:1 "${file%.*}.mp4"
                        mv "$file" "$custom_location/"
                        echo "Conversion and backup complete!"
                        break
                        ;;
                esac
            done
            break
            ;;
        "Delete")
            ffmpeg -i "$file" -c:v libx264 -c:a aac -strict experimental -b:a 128k -b:v 1200k -r 30 -progress pipe:1 "$dir/${filename%.*}.mp4"
              rm "$file"
              echo "Conversion and deletion complete!"
              break
              ;;
          "Leave as is")
              ffmpeg -i "$file" -c:v libx264 -c:a aac -strict experimental -b:a 128k -b:v 1200k -r 30 -progress pipe:1 "$dir/${filename%.*}.mp4"
            done
            echo "Conversion complete!"
            break
            ;;
    esac
done
