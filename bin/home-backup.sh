#!/usr/bin/env bash

# Back up home dir to backup drive.

HOME_DIR="/home/hunmonk"
BACKUP_DIR="/media/hunmonk/HOME_BACKUP"

if [ -r "${HOME_DIR}" ] && [ -w "${BACKUP_DIR}" ]; then
  rsync \
    -av --progress --delete \
    --exclude '.cache' \
    ${HOME_DIR}/ ${BACKUP_DIR}
else
  echo "ERROR: ${HOME_DIR} not readable, or ${BACKUP_DIR} not writeable"
fi
