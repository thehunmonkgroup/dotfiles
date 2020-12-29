#!/usr/bin/env bash

PROGNAME="$(basename $0)"
OLD_BASE_PROJECT="${1}"
NEW_BASE_PROJECT="${2}"

function usage() {
  echo "
Usage: ${PROGNAME} <old_base_project> <new_base_project>

Recursively move a project and all subprojects to a new base project.

  old_base_project: Old base project name.
  new_base_project: New base project name.

With no arguments, show this help.

EXAMPLE:

You have:

foo.bar
foo.bar.baz
foo.bar.bing

...and you want to move all projects and subprojects under foo.bar to
bing.bong:

  ${PROGNAME} foo.bar bing.bong

...and you get:

bing.bong
bing.bong.baz
bing.bong.bing
"
}

if [ $# -ne 2 ]; then
  usage
  exit 1
fi

uuids="$(task project:"${1}" _uuids)"
old_base_project_size="${#OLD_BASE_PROJECT}"

for uuid in $uuids; do
  project="$(task verbose=nothing ${uuid} | grep -m 1 ^Project | awk '{print $2}')"
  subproject="${project:${old_base_project_size}}"
  new_project="${NEW_BASE_PROJECT}${subproject}"
  task rc.confirmation=off ${uuid} modify project:"${new_project}"
done
