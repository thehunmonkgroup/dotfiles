#!/usr/bin/env bash

# Shell script for viewing/updating CircleAnywhere subscriptions.

PROG=`basename ${0}`
#CONNECT_SERVER="staging-connect.stirlab.net"
#CONNECT_SERVER="connect.circleanywhere.com"
CONNECT_SERVER="connect.local-circleanywhere.com"
SERVER_SECRET="7DFC9213-F524-443A-9F2A-12A0C943F297"

usage() {
echo "
${PROG} <get> <google_user_id>
${PROG} <post> <google_user_id> <subscribe|unsubscribe>
"
}

generate_token() {
  local google_user_id=${1}
  local token_string="${google_user_id}${SERVER_SECRET}"
  local valid_token=`echo -n "${token_string}" | openssl dgst -sha1 | awk '{print $2}'`
  echo ${valid_token}
}

method=${1}
google_user_id=${2}
action=${3}

if [ "${method}" != "get" ] && [ "${method}" != "post" ]; then
  echo
  echo "ERROR: method must be one of: get, post"
  usage
  exit 1
elif [ "${method}" = "post" ] && [ "${action}" != "subscribe" ] && [ "${action}" != "unsubscribe" ]; then
  echo
  echo "ERROR: action must be one of: subscribe, unsubscribe"
  usage
  exit 1
fi

if [ -z "${google_user_id}" ]; then
  echo "ERROR: google_user_id is required"
  usage
  exit 1
fi

token=`generate_token ${google_user_id}`

case ${method} in
  get)
    curl --silent "https://${CONNECT_SERVER}/user/subscription/${google_user_id}?token=${token}" | python -m json.tool
    ;;
  post)
    curl --silent --data "token=${token}&action=${action}" "https://${CONNECT_SERVER}/user/subscription/${google_user_id}" | python -m json.tool
    ;;
esac

