#!/usr/bin/env bash

SCRIPT_NAME=$(basename $0)
AUDIO_EXTENSION="wav"
COMBINED_CONTAINER_EXTENSION="mkv"

function usage() {
    echo "
Usage: ${SCRIPT_NAME} all | <filepath1> [filepathN]

Split mp4 files into separate audio/video files

  filepathN: Path to the file.
"
}

function split_file() {
  local filepath="${1}"
  echo "Splitting ${filepath} into separate audio/video files"
  local dir="$(dirname -- "${filepath}")"
  local fullname="$(basename -- "${filepath}")"
  local filename="${fullname%.*}"
  local extension="${fullname##*.}"
  local image_dir="${dir}/image"
  local video_dir="${dir}/video"
  local audio_dir="${dir}/audio"
  local combined_filepath="${video_dir}/${filename}.${COMBINED_CONTAINER_EXTENSION}"
  local combine_result=1
  if [ ! -d ${image_dir} ]; then
    mkdir -v ${image_dir}
  fi
  if [ ! -d ${video_dir} ]; then
    mkdir -v ${video_dir}
  fi
  if [ ! -d ${audio_dir} ]; then
    mkdir -v ${audio_dir}
  fi
  if [ "${extension}" = "JPG" ]; then
    echo "Image file, moving to ${image_dir}"
    mv -v ${filepath} ${image_dir}/
    return
  fi
  local test_audio_track="$(ffprobe -i ${filepath} -show_streams -select_streams a -loglevel error)"
  local has_audio_track=
  if [ -n "${test_audio_track}" ]; then
    has_audio_track=1
  fi
  local video_filepath="${video_dir}/${filename}.${extension}"
  if [ "${has_audio_track}" = "1" ]; then
    if [ ! -f ${video_filepath} ]; then
      echo "Extracting video-only file to ${video_filepath}"
      ffmpeg -i "${filepath}" -vcodec copy -an "${video_filepath}"
    fi
  else
    mv -v ${filepath} ${video_filepath}
  fi
  if [ "${has_audio_track}" = "1" ]; then
    local audio_filepath="${audio_dir}/${filename}.${AUDIO_EXTENSION}"
    if [ ! -f ${audio_filepath} ]; then
      echo "Extracting audio-only file to ${audio_filepath}"
      ffmpeg -i "${filepath}" -vn "${audio_filepath}"
      if [ ! -f ${combined_filepath} ]; then
        echo "Recombining  ${video_filepath} and ${audio_filepath} to ${combined_filepath}..."
        ffmpeg -i ${video_filepath} -i ${audio_filepath} -c copy ${combined_filepath}
        combine_result=$?
      fi
    fi
  fi
  if [ -f ${filepath} ] && [ -f ${video_filepath} ] && ( [ -z "${has_audio_track}" ] || ( [ "${has_audio_track}" = "1" ] &&  [ -f ${audio_filepath} ] ) ); then
    echo "File already split, removing original: ${filepath}"
    rm -v ${filepath}
    if [ -f ${combined_filepath} ] && [ ${combine_result} -eq 0 ]; then
      echo "Cleaning up uneeded files ${video_filepath} and ${audio_filepath}..."
      rm -v ${video_filepath} ${audio_filepath}
    fi
  fi
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

if [ "${1}" = "all" ]; then
  echo "Splitting all files in current directory..."
  for filepath in $(find . -maxdepth 1 -not -type d); do
    split_file "${filepath}"
  done
else
  for filepath in "$@"; do
    split_file "${filepath}"
  done
fi


echo "Done!"

# vi: ft=sh
