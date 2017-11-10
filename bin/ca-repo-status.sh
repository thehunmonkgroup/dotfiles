#!/bin/bash

# Shortcut to do 'git status' on all CA-related repositories.

REPOS="janus-gateway
openhangout
circleanywhere/branding/circleanywhere
circleanywhere/branding/facilitateanywhere
circleanywhere/stirlab-video
circleanywhere/unhangout
circleanywhere/connect.circleanywhere.com-salt
circleanywhere/videoserver-listener"

command=${1-git st}

for repo in ${REPOS}; do
  echo "*********************************"
  echo "${repo}"
  echo "*********************************"
  echo
  cd ~/git/${repo}
  ${command}
  echo
  echo
done
