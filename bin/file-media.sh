#!/usr/bin/env bash

SCRIPT_NAME=$(basename $0)
DEFAULT_STORAGE_LOCATION="/media/hunmonk/storage/video"

function usage() {
    echo "
Usage: ${SCRIPT_NAME} [dry-run|execute]

Move files into the correct media storage directory based on modified time.

  dry-run: Just print what would be done
  execute: Actually move the files.
"
}

execute() {
  local op="${1}"
  local full_name extension extension_lower main_dir full_dir cmd
  for filepath in $(find . -maxdepth 1 -type f -regextype posix-egrep -iregex '.+\.(jpg|png|gpr|mp4)$'); do
    full_name="$(basename -- "${filepath}")"
    extension="${full_name##*.}"
    extension_lower="${extension,,}"
    main_dir="$(date -r ${filepath} "+%Y-%m-%d")"
    if [ "${extension_lower}" = "mp4" ]; then
      full_dir="${DEFAULT_STORAGE_LOCATION}/${main_dir}/video"
    else
      full_dir="${DEFAULT_STORAGE_LOCATION}/${main_dir}/image"
    fi
    cmd="mv -v ${filepath} ${full_dir}/${full_name}"
    echo "Command to run: ${cmd}"
    if [ "${op}" = "execute" ]; then
      mkdir -pv ${full_dir}
      ${cmd}
    fi
  done
}

if [ "${1}" = "dry-run" ] || [ "${1}" = "execute" ]; then
  execute "${1}"
else
  usage
  exit 1
fi
