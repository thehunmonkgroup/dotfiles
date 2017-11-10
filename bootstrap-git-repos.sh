#!/usr/bin/env bash

SCRIPT_NAME=`basename $0`

usage() {
echo "
Usage: $SCRIPT_NAME -h
Usage: $SCRIPT_NAME [-c <path>] -v
Usage: $SCRIPT_NAME [-g <path>]

Check out/update all configured git repositories.

  -h: This help text.
  -c: Optional. Path to the config file, default is: ~/.git-repositories
  -v: Optional. Verify if all repositories are up to date.
  -g: Generate a config file from repositories in a parent directory. Only
      searches one layer deep in the parent directory, and skips any
      directories that are not git repositories. Fetch URLs are obtained from
      the 'origin' remote.

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

CAVEATS:

Full git commit hashes must be used for revisions in the configuration for the
verify operation to work correctly.
"
}

echoerr() {
  cat <<< "$@" 1>&2;
  RETVAL=1
}

add_output() {
  OUTPUT="${OUTPUT}
${1}"
}

generate_repositories_config_from_directory() {
  local path="${1/#\~/$HOME}"
  if [[ -d "${path}" ]]; then
    local cwd=`pwd`
    cd ${path}
    local repo_dirs=`ls -1`
    for repo_dir in $repo_dirs; do
      if [[ -d "${repo_dir}" ]]; then
        cd ${repo_dir}
        head_rev=`git rev-parse HEAD 2>/dev/null`
        if [ $? -eq 0 ]; then
          remote=`git remote get-url origin`
          if [ $? -eq 0 ]; then
            add_output "${remote}#${head_rev}#${path}/${repo_dir}"
          else
            echo "WARN: ${path}/${repo_dir} does not have an origin remote"
          fi
        else
          echo "WARN: ${path} is not a git repository"
        fi
        cd ..
      fi
    done
    cd "${cwd}"
    echo "${OUTPUT}"
    exit 0
  else
    echoerr "ERROR: ${path} is not a valid directory"
    exit 1
  fi
}

update_repo() {
  local url="${1}"
  local rev="${2}"
  local path="${3}"
  local setup_succeeded=
  if ! [[ -d "${path}" ]]; then
    if [ "${verify}" = "yes" ]; then
      add_output "Missing repository ${url} at ${path}"
    else
      git clone "${url}" "${path}"
      if [ $? -eq 0 ]; then
        setup_succeeded=1
      else
        echoerr "ERROR: Could not clone ${url} to ${path}"
      fi
    fi
  else
    cd "${path}"
    head_rev=`git rev-parse HEAD 2>/dev/null`
    if [ $? -eq 0 ]; then
      if [ "${head_rev}" != "${rev}" ]; then
        if [ "${verify}" = "yes" ]; then
            add_output "${url} at ${path} needs update: ${head_rev} => ${rev}"
        else
          setup_succeeded=1
          git pull
        fi
      fi
    else
      echoerr "ERROR: ${path} does not appear to be a git repository"
    fi
  fi
  if [ "${setup_succeeded}" = "1" ]; then
    cd "${path}"
    git reset --hard ${rev} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echoerr "ERROR: could not reset checkout at ${path} to revision ${rev}"
    fi
  fi
}

parse_line() {
  local line="${1}"
  local op="${2}"
  local text=`echo ${line} | xargs`
  if [ -n "${text}" ] && ! [[ "${text:0:1}" = "#" ]]; then
    IFS='#'; parts=(${text}); unset IFS;
    local url="${parts[0]}"
    local rev="${parts[1]}"
    local path="${parts[2]/#\~/$HOME}"
    if [ -z "${rev}" ]; then
      echoerr "CONFIG ERROR: missing revision on line '${text}'"
    elif [ -z "${path}" ]; then
      echoerr "CONFIG ERROR: missing path on line '${text}'"
    else
      if [ "${op}" = "execute" ]; then
        update_repo "${url}" "${rev}" "${path}"
      fi
    fi
  fi
}

read_config() {
  local op="${1}"
  while IFS='' read -r line || [[ -n "$line" ]]; do
    parse_line "${line}" "${op}"
  done < "${config_file}"
}

main() {
  if [ -r "${config_file}" ]; then
    local cwd=`pwd`
    read_config
    if [ ${RETVAL} -eq 0 ]; then
      read_config execute
    fi
    cd "${cwd}"
  else
    echo
    echoerr "ERROR: file '${config_file}' not readable"
  fi
}

verify="no"
OUTPUT=
config_file="${HOME}/.git-repositories"
generate_parent_directory=
while getopts ":hc:vg:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    c)
      config_file="${OPTARG/#\~/$HOME}"
      ;;
    v)
      verify="yes"
      ;;
    g)
      generate_repositories_config_from_directory "${OPTARG}"
      exit 0
      ;;
    \?)
      echoerr "Invalid option: -${OPTARG}" >&2
      usage
      exit 1
      ;;
    :)
      echoerr "Option -${OPTARG} requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

RETVAL=0
main

if [ ${RETVAL} -eq 0 ]; then
  if [ -z "${OUTPUT}" ]; then
    add_output "All repositories up to date"
  fi
fi

echo "${OUTPUT}"
exit ${RETVAL}
