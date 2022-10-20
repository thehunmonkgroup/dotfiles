#!/usr/bin/env bash

PROGNAME="$(basename $0)"

function usage() {
  echo "
Usage: ${PROGNAME} start | stop

Start/stop all Apartment Lines development servers.

  start: Start servers.
  standalone: Start standalone server.
  stop: Stop servers.

With no arguments, show this help.
"
}

vagrant_dir="${HOME}/vagrant"
op="${1}"

server_list="data1-central.local
data2-central.local
gw-admin.local
gw-central.local
gw-east.local
union1-east.local
voice1-central.local
web1-central.local
orch.local
repo.local
monitor.local"

standalone_server="union1-east.local"

if [ $# -ne 1 ] || ( [ "${op}" != "start" ] && [ "${op}" != "standalone" ] && [ "${op}" != "stop" ] ); then
  usage
  exit 1
fi

_box_command() {
  local cmd="${1}"
  shift
  local box_list=("$@")
  for box_dir in "${box_list[@]}"; do
    echo "Performing command '${cmd}' for box '${box_dir}'"
    if [ -f "${vagrant_dir}/${box_dir}/Vagrantfile" ]; then
      cd ${vagrant_dir}/${box_dir}
      vagrant ${cmd}
    else
      echo "ERROR: ${vagrant_dir}/${box_dir} has no Vagrantfile"
    fi
  done
}

reverse() {
  tac <(echo "$@" | tr ' ' '\n') | tr '\n' ' '
}

function start_servers() {
  _box_command up $(echo $server_list)
}

function start_standalone_server() {
  _box_command up $(echo ${standalone_server})
  ssh ${standalone_server} /root/bin/standalone-server.sh
}

function stop_servers() {
  _box_command halt $(reverse $server_list)
}

case $op in
  start)
    start_servers
    ;;
  standalone)
    start_standalone_server
    ;;
  stop)
    stop_servers
    ;;
esac
