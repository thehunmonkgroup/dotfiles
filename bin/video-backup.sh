#!/usr/bin/env bash

# NOTE: This script is no longer used.

# Back up main video drive to backup drive.

VIDEO_DIR="/media/hunmonk/VIDEO"
BACKUP_DIR="/media/hunmonk/BACKUP/VIDEO"

if [ -r "${VIDEO_DIR}" ] && [ -w "${BACKUP_DIR}" ]; then
  rsync \
    -av --progress --delete \
    --exclude 'CacheClip' \
    --exclude '.gallery' \
    --exclude 'lost+found' \
    --exclude '.Trash*' \
    ${VIDEO_DIR}/ ${BACKUP_DIR}
  ret=$?
  logger "[VIDEO BACKUP] Completed successfully"
  exit ${ret}
else
  message="ERROR: ${VIDEO_DIR} not readable, ${BACKUP_DIR} not writeable, or rsync error"
  logger "[VIDEO BACKUP] ${message}"
  /usr/bin/notify-send "Video backup error" "${message}"
  exit 1
fi
