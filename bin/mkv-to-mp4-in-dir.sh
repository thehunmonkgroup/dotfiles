#!/bin/bash

# This script expects a single argument in the format [YY]MMDDhhmm
# where YY is the year, MM is the month, DD is the day,
# hh is the hour, and mm is the minute.

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Please provide a timestamp in the format [YY]MMDDhhmm"
    exit 1
fi

# Loop over every .mkv file in the current directory
for input in *.mkv; do
  # Create output filename by replacing .mkv extension with .mp4
  output="${input%.mkv}.mp4"

  # Use FFmpeg to convert .mkv to .mp4
  ffmpeg -i "$input" -vcodec copy -acodec aac "$output"

  # Change the file's timestamps to the provided timestamp
  touch -t $1 "$output"
done
