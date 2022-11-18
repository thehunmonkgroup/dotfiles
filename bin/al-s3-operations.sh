#!/usr/bin/env bash

PROGNAME="$(basename $0)"

S3_PRODUCTION_CONFIG="${HOME}/.s3cfg.al-production"
S3_STAGING_CONFIG="${HOME}/.s3cfg.al-staging"
S3_PRODUCTION_CURRENT_BUCKET="s3://apartmentlines-production-current"
S3_STAGING_CURRENT_BUCKET="s3://apartmentlines-staging-current"
LOCAL_DOWNLOADS_DIR="~/Downloads"

function usage() {
  echo "
Usage: ${PROGNAME} help | update-staging-databases

 Operations on Apartment Lines S3 storage.

  update-staging-databases: Copies Apartment Lines current production databases to staging.
  help: This help.

With no arguments, show this help.
"
}

op="${1}"

update_staging_databases() {
  local DATABASES="apartmentlines.sql.gz apartmentlines_drupal.sql.gz asterisk_realtime.sql.gz"
  echo "Updating the following databases from production to staging: ${DATABASES}"
  for database in ${DATABASES}; do
    echo "Downloading ${database} from ${S3_PRODUCTION_CURRENT_BUCKET}..."
    s3cmd -c ${S3_PRODUCTION_CONFIG} get ${S3_PRODUCTION_CURRENT_BUCKET}/${database} ${LOCAL_DOWNLOADS_DIR}/${database}
    echo "Uploading ${database} to ${S3_STAGING_CURRENT_BUCKET}..."
    s3cmd -c ${S3_STAGING_CONFIG} put ${LOCAL_DOWNLOADS_DIR}/${database} ${S3_STAGING_CURRENT_BUCKET}/${database}
    echo "Cleanup up ${LOCAL_DOWNLOADS_DIR}/${database}..."
    rm -v ${LOCAL_DOWNLOADS_DIR}/${database}

  done
}

case ${op} in
  update-staging-databases)
    update_staging_databases
    ;;
  help)
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
