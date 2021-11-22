#!/usr/bin/env bash

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
else
  echo "ERROR: ${VIDEO_DIR} not readable, or ${BACKUP_DIR} not writeable"
fi
