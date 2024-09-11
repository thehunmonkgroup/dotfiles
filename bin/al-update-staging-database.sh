#!/usr/bin/env bash

PROGNAME="$(basename $0)"

ORCH_STAGING="orch.al-staging.com"
UNION_STAGING="union1-east.al-staging.com"
DATA1_STAGING="data1-central.al-staging.com"
ORCH_LOCAL="orch.local"
UNION_LOCAL="union1-east.local"
DATA1_LOCAL="data1-central.local"

function usage() {
  echo "
Usage: ${PROGNAME} help | execute

 Update Apartment Lines databases on staging and local environments.

  execute: Perform the following actions:
           1. Update staging databases:
              - Migrate production S3 databases to staging
              - Update databases on staging servers
              - Reconfigure database replication
           2. Update local databases:
              - Update databases on local servers
              - Reconfigure database replication
              - Restart local servers in standalone mode
  help: Display this help message.

With no arguments, show this help.
"
}

op="${1}"

update_staging_databases() {
  echo "Migrating production S3 databases to staging..."
  ${HOME}/bin/al-s3-operations.sh update-staging-databases
  echo "Testing database connection on ${DATA1_STAGING}..."
  ssh ${DATA1_STAGING} "mariadb -e 'SELECT 1'"
  if [ $? -eq 0 ]; then
    echo "Removing previous data dumps from ${DATA1_STAGING}..."
    ssh ${DATA1_STAGING} "rm -v /var/db/*.sql.gz"
    if [ $? -eq 0 ]; then
      echo "Stopping slave on  ${UNION_STAGING}..."
      ssh ${UNION_STAGING} "mariadb -e 'STOP SLAVE'"
      if [ $? -eq 0 ]; then
        echo "Updating databases on ${DATA1_STAGING}..."
        ssh ${DATA1_STAGING} "salt-call state.sls server.data.apartmentlines.database"
        if [ $? -eq 0 ]; then
          echo "Reconfiguring database replication from ${ORCH_STAGING}..."
          ssh ${ORCH_STAGING} "salt-run state.orch orch.configure-database-replication"
          if [ $? -eq 0 ]; then
            echo "Successfully upgraded staging databases!"
            return 0
          else
            echo "ERROR: could not reconfigure database replication from ${ORCH_STAGING}"
          fi
        else
          echo "ERROR: could not update databases on ${DATA1_STAGING}, aborting"
        fi
      else
        echo "ERROR: could not stop slave on ${UNION_STAGING}, aborting"
      fi
    else
      echo "ERROR: could not remove previous data dumps on ${DATA1_STAGING}, aborting"
    fi
  else
    echo "ERROR: could not connect to database on ${DATA1_STAGING}, aborting"
  fi
  exit 1
}

update_local_databases() {
  echo "Starting all local servers..."
  ${HOME}/bin/al-vagrant.sh start
  echo "Testing database connection on ${DATA1_LOCAL}..."
  ssh ${DATA1_LOCAL} "mariadb -e 'SELECT 1'"
  if [ $? -eq 0 ]; then
    echo "Removing previous data dumps from ${DATA1_LOCAL}..."
    ssh ${DATA1_LOCAL} "rm -v /var/db/*.sql.gz"
    if [ $? -eq 0 ]; then
      echo "Stopping slave on  ${UNION_LOCAL}..."
      ssh ${UNION_LOCAL} "mariadb -e 'STOP SLAVE'"
      if [ $? -eq 0 ]; then
        echo "Updating databases on ${DATA1_LOCAL}..."
        ssh ${DATA1_LOCAL} "salt-call state.sls server.data.apartmentlines.database"
        if [ $? -eq 0 ]; then
          echo "Reconfiguring database replication from ${ORCH_LOCAL}..."
          ssh ${ORCH_LOCAL} "salt-run state.orch orch.configure-database-replication"
          if [ $? -eq 0 ]; then
            echo "Successfully upgraded local databases!"
            echo "Stopping all local servers..."
            ${HOME}/bin/al-vagrant.sh stop
            echo "Starting standalone server..."
            ${HOME}/bin/al-vagrant.sh standalone
            exit 0
          else
            echo "ERROR: could not reconfigure database replication from ${ORCH_LOCAL}"
          fi
        else
          echo "ERROR: could not update databases on ${DATA1_LOCAL}, aborting"
        fi
      else
        echo "ERROR: could not stop slave on ${UNION_LOCAL}, aborting"
      fi
    else
      echo "ERROR: could not remove previous data dumps on ${DATA1_LOCAL}, aborting"
    fi
  else
    echo "ERROR: could not connect to database on ${DATA1_LOCAL}, aborting"
  fi
  exit 1
}

case ${op} in
  execute)
    update_staging_databases
    if [ $? -eq 0 ]; then
      update_local_databases
    fi
    ;;
  help)
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
