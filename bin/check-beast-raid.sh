#!/bin/bash

TARGET_MACHINE="192.168.1.100"
TARGET_SSH_HOST="beast"
TARGET_USER="hunmonk"
RAID_ALERT_FILE="/home/${TARGET_USER}/Desktop/RAID_ALERTS.log"
ENSURE_TASK_SCRIPT="${HOME}/bin/ensure-task.sh"

# Ping check
if ping -c 1 -W 1 ${TARGET_MACHINE} &> /dev/null; then
    # SSH check for RAID_ALERTS.log file
    if ssh ${TARGET_SSH_HOST} "test -f ${RAID_ALERT_FILE}"; then
        # Run ensure-task.sh if file exists
        ${ENSURE_TASK_SCRIPT} beast_raid "RAID issue on beast"
    fi
fi
