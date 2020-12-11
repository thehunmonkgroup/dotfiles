#!/usr/bin/env bash

SCRIPT_NAME=$(basename $0)
AUDIO_EXTENSION="aac"

function usage() {
    echo "
Usage: ${SCRIPT_NAME} <filepath1> [filepathN]

Split mp4 files into separate audio/video files

  filepathN: Path to the file.
"
}

function split_file() {
  local filepath="${1}"
  local dir="$(dirname -- "${filepath}")"
  local fullname="$(basename -- "${filepath}")"
  local filename="${fullname%.*}"
  local extension="${fullname##*.}"
  local video_filepath="${dir}/${filename}-video.${extension}"
  local audio_filepath="${dir}/${filename}-audio.${AUDIO_EXTENSION}"

  echo "Extracting audio-only file to ${audio_filepath}"
  ffmpeg -i "${filepath}" "${audio_filepath}"
  echo "Extracting video-only file to ${video_filepath}"
  ffmpeg -i "${filepath}" -c copy -an "${video_filepath}"
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

for filepath in "$@"; do
    echo "Splitting ${filepath} into separate audio/video files"
    split_file "${filepath}"
done

echo "Done!"

# vi: ft=sh
