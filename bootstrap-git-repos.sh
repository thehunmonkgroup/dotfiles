#!/usr/bin/env bash

SCRIPT_NAME=`basename $0`

usage() {
echo "
Usage: $SCRIPT_NAME -h|--help
Usage: $SCRIPT_NAME [config]

Check out/update all configured git repositories.

  config: Path to the config file, default is: ~/.git-repositories

The config file syntax is extremly simple:

 - Lines starting with a # or empty space are ignored.
 - For all repositories, use the following single line format:
   [clone-url]#[rev]#[checkout-path]

   Where [clone-url] is the URL of the git repo, [rev] is the desired HEAD
   revision, and [checkout-path] is the path to the checkout.

   E.g., the following config line:

   https://github.com/rg3/youtube-dl#master#/usr/local/youtube-dl

   Would clone the https://github.com/rg3/youtube-dl repository to
   /usr/local/youtube-dl, then force reset HEAD to the master revision.
"
}

update_repo() {
  local url="${1}"
  local rev="${2}"
  local path="${3}"
  local setup_succeeded=
  if ! [[ -d "${path}" ]]; then
    git clone "${url}" "${path}"
    if [ $? -eq 0 ]; then
      setup_succeeded=1
    else
      echo "ERROR: Could not clone ${url} to ${path}"
    fi
  else
    cd "${path}"
    git rev-parse > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      setup_succeeded=1
      git pull
    else
      echo "ERROR: ${path} does not appear to be a git repository"
    fi
  fi
  if [ "${setup_succeeded}" = "1" ]; then
    cd "${path}"
    git reset --hard ${rev} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "ERROR: could not reset checkout at ${path} to revision ${rev}"
    fi
  fi
}

parse_line() {
  local line="${1}"
  local text=`echo ${line} | xargs`
  if [ -n "${text}" ] && ! [[ "${text:0:1}" = "#" ]]; then
    IFS='#'; parts=(${text}); unset IFS;
    local url="${parts[0]}"
    local rev="${parts[1]}"
    local path="${parts[2]/#\~/$HOME}"
    if [ -z "${rev}" ]; then
      echo "ERROR: missing revision on line '${text}'"
    elif [ -z "${path}" ]; then
      echo "ERROR: missing path on line '${text}'"
    else
      echo "Git clone URL: ${url}"
      echo "Revision: ${rev}"
      echo "Checkout path: ${path}"
      update_repo "${url}" "${rev}" "${path}"
    fi
  fi
}

main() {
  local config_file="${HOME}/.git-repositories"
  if [ $# -gt 1 ] || [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
    usage
  elif [ $# -eq 1 ]; then
    config_file="${1}"
  fi
  if [ -r "${config_file}" ]; then
    local cwd=`pwd`
    while IFS='' read -r line || [[ -n "$line" ]]; do
      parse_line "${line}"
    done < "${config_file}"
    cd "${cwd}"
  else
    echo
    echo "ERROR: file '${config_file}' not readable"
    usage
  fi
}

main $@
