#!/usr/bin/env bash

# Shell script for checking/adjusting System76 Power profile.

PROG=`basename ${0}`
POWER_BIN="/usr/bin/system76-power"
POWER_PROFILE_DEFAULT="max_lifespan"

usage() {
echo "
${PROG} help
  This help.
${PROG} show
  Show current profile.
${PROG} list
  List available profiles.
${PROG} [custom_profile]
  Switch to provided profile, default: ${POWER_PROFILE_DEFAULT}.
"
}

power_profile_get_current() {
  local current_profile="$(${POWER_BIN} charge-thresholds)"
  echo "${current_profile}"
}

power_profile_is_current() {
  local profile="${1}"
  local contains_current_profile="$(power_profile_get_current | grep "${profile}")"
  if [ -z "${contains_current_profile}" ]; then
    return 1
  else
    return 0
  fi
}

list_power_profiles() {
  ${POWER_BIN} charge-thresholds --list-profiles
}

set_power_profile() {
  local profile="${1}"
  echo "Checking if current profile is: ${profile}"
  power_profile_is_current "${profile}"
  if [ $? -eq 1 ]; then
    echo "Power profile not set to ${profile}, setting"
    ${POWER_BIN} charge-thresholds --profile ${profile}
  else
    echo "Power profile already set to: ${profile}"
  fi
}

if [ "${1}" == "help" ]; then
  usage
  exit 1
elif [ "${1}" == "show" ]; then
  power_profile_get_current
elif [ "${1}" == "list" ]; then
  list_power_profiles
else
  set_power_profile "${1:-${POWER_PROFILE_DEFAULT}}"
fi
