#!/usr/bin/env bash

NORMAL_IDLE_DELAY=300

usage() {
  echo "Usage: $(basename ${0}) enable|disable|status

Quick CLI way to keep the screen awake permanently.

Adjusts gsettings org.gnome.desktop.session idle-delay
"
}

if [ $# -ne 1 ]; then
  usage
  exit 1
else
  setting="org.gnome.desktop.session idle-delay"
  case ${1} in
    status)
      value=$(gsettings get ${setting} | awk '{print $2}')
      if [ "${value}" = "0" ]; then
        echo "Coffee is ON"
      else
        echo "Coffee is OFF"
      fi
      ;;
    enable)
      gsettings set ${setting} 0
      ${0} status
      ;;
    disable)
      gsettings set ${setting} ${NORMAL_IDLE_DELAY}
      ${0} status
      ;;
    *)
      usage
      ;;
  esac
  exit 0
fi
