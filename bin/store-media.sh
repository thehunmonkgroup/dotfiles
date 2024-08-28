#!/usr/bin/env bash

PROGNAME="$(basename $0)"

DEFAULT_USER="hunmonk"
DEFAULT_STORAGE_LOCATION="/media/hunmonk/storage/video"

function usage() {
  echo "
Usage: ${PROGNAME} [help] | [location]

Move media out of a DCIM storage directory, and into a storage location,
grouped by YYYY-MM-DD folders based on file created time.

All directory names in /media/${DEFAULT_USER} will be searched for any
directories named 'DCIM', and all .MP4/.JPG/.GPR files in any directories found
will be:

 * Examined for creation time
 * Moved to a directory in the final storage location

  location: Location for storage: Default: ${DEFAULT_STORAGE_LOCATION}.
"
}

location=${1:-$DEFAULT_STORAGE_LOCATION}
source_base_dir="/media/${DEFAULT_USER}"

if [ $# -gt 1 ] || [ "${location}" = "help" ]; then
  usage
  exit 1
fi

_find_removable_media_dirs() {
  local removable_media_dir_regex='^[0-9-]+$'
  local removable_media_dirs=""
  local all_dirs="$(find ${source_base_dir} -mindepth 1 -maxdepth 1 -type d)"
  for dir in ${all_dirs}; do
    if [[ $(basename ${dir}) =~ ${removable_media_dir_regex} ]]; then
      removable_media_dirs="${removable_media_dirs} $dir"
    fi
  done
  removable_media_dirs="$(echo "${removable_media_dirs}" | awk '{$1=$1};1')"
  echo "${removable_media_dirs}"
}

_find_dcim_dirs() {
  local media_dir="${1}"
  local dcim_dirs="$(find ${media_dir} -type d -name DCIM)"
  echo "${dcim_dirs}"
}

_move_media_files() {
  local source_dir="${1}"
  echo "Moving files from ${source_dir} to ${location}..."
  local files="$(find ${source_dir} -type f \( -name "*.JPG" -o -name "*.GPR" -o -name "*.MP4" \))"
  for file in $files; do
    local modify_date="$(stat -c %y ${file} | awk '{print $1}')"
    local location_subdir="${location}/${modify_date}"
    if [ ! -d "${location_subdir}" ]; then
      echo "${location_subdir} does not exist, creating..."
      mkdir -v ${location_subdir}
    fi
    mv -v "$file" "${location_subdir}/"
  done
}

_clean_media_dir() {
  local source_dir="${1}"
  echo "Cleaning unneeded files from ${source_dir}..."
  local files="$(find ${source_dir} -type f \( -name "*.THM" -o -name "*.LRV" \))"
  for file in $files; do
    rm -v "$file"
  done
}

execute() {
  local removable_media_dirs="$(_find_removable_media_dirs)"
  for media_dir in ${removable_media_dirs}; do
    local dcim_dirs="$(_find_dcim_dirs "${media_dir}")"
    for dir in ${dcim_dirs}; do
      _move_media_files "${dir}"
      _clean_media_dir "${dir}"
    done
  done
}

if [ -w "${location}" ]; then
  execute
else
  echo "ERROR: ${location} does not exist, or is not writable"
fi
