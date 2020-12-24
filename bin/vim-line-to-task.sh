#!/usr/bin/env bash

DEFAULT_PROJECT="$(task _show | grep default\.project | cut -f 2 -d =)"
DEFAULT_TASK="None"

while read line; do
  if [ -n "${ONENOTE_TASK}" ]; then
    description="$(task rc.verbose=nothing ${ONENOTE_TASK} | grep -m 1 ^Description | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}')"
    project="$(task rc.verbose=nothing ${ONENOTE_TASK} | grep -m 1 ^Project | awk '{print $2}')"
  else
    description="${DEFAULT_TASK}"
    project="${DEFAULT_PROJECT}"
  fi
  task rc.verbose=no add "${line}" project:"${project}"
  if [ $? -eq 0 ]; then
    echo "Converted '${line}' to task"
    echo "Project: ${project}"
    echo "From task: ${description}"
    exit 0
  else
    echo "ERROR: could not convert '${line}' to task"
    exit 1
  fi
done < "${1:-/dev/stdin}"
