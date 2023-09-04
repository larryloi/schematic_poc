#!/bin/bash

  FAIL_EXIT()
    {
      echo "=="
      echo "== ${1} "
      echo "=="
      echo "== Usage: bash scripts/dbmigrate-up.sh <up|down|to> [migration version]"
      echo "== For example: bash scripts/db-migrate.sh up"
      echo "== For example: bash scripts/db-migrate.sh down"
      echo "== For example: bash scripts/db-migrate.sh to 201908280902"
      echo "=="
      exit 1
    }


  DB_MIGRATION()
    {
      if [[ $DB_ACTION == "up" ]]; then
        rake db:migrate:up DB_USER=${DB_USER} DB_DATABASE=${DB_NAME} DB_PORT=${DB_PORT} DB_PASSWORD=${DB_PASSWORD} DB_HOST=${DB_HOST} SCHEMA_TABLE=${SCHEMA_TABLE}

      elif [[ $DB_ACTION == "down" ]]; then
        rake db:migrate:down DB_USER=${DB_USER} DB_DATABASE=${DB_NAME} DB_PORT=${DB_PORT} DB_PASSWORD=${DB_PASSWORD} DB_HOST=${DB_HOST} SCHEMA_TABLE=${SCHEMA_TABLE}

      elif [[ $DB_ACTION == "to" ]]; then
        rake db:migrate:to VERSION=${dbversion} DB_USER=${DB_USER} DB_DATABASE=${DB_NAME} DB_PORT=${DB_PORT} DB_PASSWORD=${DB_PASSWORD} DB_HOST=${DB_HOST} SCHEMA_TABLE=${SCHEMA_TABLE}

      fi
    }

#============================
# Main
#=============================
#. $RVM_PATH/scripts/rvm
export DB_ACTION=$1
export DB_VERSION=$2
export MIGRATION_PATH=${MIGRATION_BASE}
#echo $DB_TARGET; echo $DB_ACTION; echo $DB_VERSION

  if  [[ -z "$DB_ACTION" ]]; then
     FAIL_EXIT "Missing parameters. "

  elif [[ "$DB_ACTION" != "up" ]] && [[ "$DB_ACTION" != "down" ]] && [[ "$DB_ACTION" != "to" ]]; then
     FAIL_EXIT "Incorrect action parameters."

  elif [[ "$DB_ACTION" == "to" ]] && [[ -z "$DB_VERSION" ]]; then
     FAIL_EXIT "Missing db migration version parameters."

  else
     DB_MIGRATION
  fi
