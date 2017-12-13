#!/bin/bash

# Shortcut to do 'git status' on all CA-related repositories.

REPOS="stirlab/janus-gateway
stirlab/branding/circleanywhere
stirlab/branding/moxiemeet
stirlab/unhangout
stirlab/servers-salt
stirlab/connect-salt
stirlab/openhangout
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
