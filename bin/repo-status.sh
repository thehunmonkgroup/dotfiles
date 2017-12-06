#!/bin/bash

# Shortcut to do 'git status' on all CA-related repositories.

REPOS="stirlab/janus-gateway
stirlab/openhangout
stirlab/branding/circleanywhere
stirlab/branding/moxiemeet
stirlab/video-salt
stirlab/unhangout
stirlab/connect-salt
stirlab/videoserver-listener"

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
