#!/usr/bin/env zsh

# Data Download Directory
# Use /data instead of a subdirectory of the script's location.
local IMDB_DATA_DIR="/data"


# Create the data directory if it doesn't exist
mkdir -p "$IMDB_DATA_DIR" || {
  echo "Failed to create data directory: $IMDB_DATA_DIR"
  exit 1
}

# Function to download and extract a file with error handling
download_and_extract() {
  local filename="$1"
  local url="$2"
  local target_path="$IMDB_DATA_DIR/$filename"

  print "\nDownloading '$filename' from '$url'...\n"
  if ! curl -SL -o "$target_path" "$url"; then
    echo "Failed to download '$filename' from '$url'"
    return 1 # Return a non-zero exit code to indicate failure
  fi

  if ! gunzip "$target_path"; then
    echo "Failed to extract '$filename'"
    return 1
  fi
  return 0
}

# Check for sufficient disk space before downloading
# Get the available space in the directory's file system
local available_space=$(df -P "$IMDB_DATA_DIR" | tail -n 1 | awk '{print $4}') # in KB
if [[ -z "$available_space" ]]; then
  echo "Failed to determine available disk space."
  exit 1
fi

# Calculate the estimated size of all files to be downloaded (in KB)
# This is a rough estimate, and you might want to adjust the sizes.
local estimated_size=$((100000 + 100000 + 100000 + 100000 + 100000 + 100000 + 100000)) #sum of estimated sizes of all files

#check if the available space is greater than the estimated size.
if ((available_space < estimated_size)); then
  echo "Insufficient disk space.  Available: $available_space KB, Estimated required: $estimated_size KB"
  exit 1
fi

# Download and extract each file
download_and_extract "name.basics.tsv.gz" "https://datasets.imdbws.com/name.basics.tsv.gz" || exit 1
download_and_extract "title.akas.tsv.gz" "https://datasets.imdbws.com/title.akas.tsv.gz" || exit 1
download_and_extract "title.basics.tsv.gz" "https://datasets.imdbws.com/title.basics.tsv.gz" || exit 1
download_and_extract "title.crew.tsv.gz" "https://datasets.imdbws.com/title.crew.tsv.gz" || exit 1
download_and_extract "title.episode.tsv.gz" "https://datasets.imdbws.com/title.episode.tsv.gz" || exit 1
download_and_extract "title.principals.tsv.gz" "https://datasets.imdbws.com/title.principals.tsv.gz" || exit 1
download_and_extract "title.ratings.tsv.gz" "https://datasets.imdbws.com/title.ratings.tsv.gz" || exit 1

echo "All files downloaded and extracted successfully to $IMDB_DATA_DIR"
