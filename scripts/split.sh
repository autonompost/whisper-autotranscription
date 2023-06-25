#!/bin/bash

# Usage: ./distribute_files.sh <source_folder> <destination_folder> <number_of_folders>

source_folder="$1"
destination_folder="$2"
number_of_folders="$3"

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./distribute_files.sh <source_folder> <destination_folder> <number_of_folders>"
  exit 1
fi

# Create the destination folder if it doesn't exist
mkdir -p "$destination_folder"

# Create the required number of subfolders
for i in $(seq 1 $number_of_folders); do
  mkdir -p "${destination_folder}/folder${i}"
done

# Move the files from the source folder to the destination folders
file_counter=1
for file in "${source_folder}"/*; do
  if [ -f "${file}" ]; then
    folder_number=$(( (file_counter-1) % number_of_folders + 1 ))
    mv "${file}" "${destination_folder}/folder${folder_number}"
    file_counter=$((file_counter+1))
  fi
done

