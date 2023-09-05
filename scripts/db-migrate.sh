#!/bin/bash

  FAIL_EXIT()
    {
      echo "=="
      echo "== ${1} "
      echo "=="
      echo "== Usage: bash scripts/dbmigrate-up.sh <src|dst> <up|down|to> [migration version]"
      echo "== For example: bash scripts/db-migrate.sh src up"
      echo "== For example: bash scripts/db-migrate.sh dst down"
      echo "== For example: bash scripts/db-migrate.sh dst to 201908280902"
      echo "=="
      exit 1
    }

  SET_DB_VARIABLES()
    {
      if [[ "$DB_TARGET" == "dst" ]]; then
        export db_adapter=${DST_DB_ADAPTER}
        db_user=${DST_DB_USER}
        db_name=${DST_DB_NAME}
        db_port=${DST_DB_PORT}
        db_password=${DST_DB_PASSWORD}
        db_host=${DST_DB_HOST}
        schema_table=${DST_SCHEMA_TABLE}
        db_version=${DB_VERSION}
        fractional_seconds=${DST_FRACTIONAL_SECONDS}
        encoding=${DST_ENCODING}
      elif [[ "$DB_TARGET" == "src" ]]; then
        export db_adapter=${SRC_DB_ADAPTER}
        db_user=${SRC_DB_USER}
        db_name=${SRC_DB_NAME}
        db_port=${SRC_DB_PORT}
        db_password=${SRC_DB_PASSWORD}
        db_host=${SRC_DB_HOST}
        schema_table=${SRC_SCHEMA_TABLE}
        db_version=${DB_VERSION}
        fractional_seconds=${SRC_FRACTIONAL_SECONDS}
        encoding=${SRC_ENCODING}
      fi
    }

  DB_MIGRATION()
    {
    

      if [[ $DB_ACTION == "up" ]]; then
        rake db:migrate:up DB_USER=${db_user} DB_DATABASE=${db_name} DB_PORT=${db_port} DB_PASSWORD=${db_password} DB_HOST=${db_host} SCHEMA_TABLE=${schema_table} DB_ADAPTER=${db_adapter}

      elif [[ $DB_ACTION == "down" ]]; then
        rake db:migrate:down DB_USER=${db_user} DB_DATABASE=${db_name} DB_PORT=${db_port} DB_PASSWORD=${db_password} DB_HOST=${db_host} SCHEMA_TABLE=${schema_table} DB_ADAPTER=${db_adapter}

      elif [[ $DB_ACTION == "to" ]]; then
        rake db:migrate:to VERSION=${db_version} DB_USER=${db_user} DB_DATABASE=${db_name} DB_PORT=${db_port} DB_PASSWORD=${db_password} DB_HOST=${db_host} SCHEMA_TABLE=${schema_table} DB_ADAPTER=${db_adapter}

      fi
    }

#============================
# Main
#=============================
#. $RVM_PATH/scripts/rvm
export DB_TARGET=$1
export DB_ACTION=$2
export DB_VERSION=$3
export MIGRATION_PATH=${MIGRATION_BASE}
#echo $DB_TARGET; echo $DB_ACTION; echo $DB_VERSION
export MIGRATION_PATH=${MIGRATION_BASE}/$DB_TARGET
#echo $DB_TARGET; echo $DB_ACTION; echo $DB_VERSION

  if [[ -z "$DB_TARGET" ]] || [[ -z "$DB_ACTION" ]]; then
     FAIL_EXIT "Missing parameters. "

  elif [[ "$DB_TARGET" != "dst" ]] && [[ "$DB_TARGET" != "src" ]]; then
     FAIL_EXIT "Incorrect db target parameters."

  elif [[ "$DB_ACTION" != "up" ]] && [[ "$DB_ACTION" != "down" ]] && [[ "$DB_ACTION" != "to" ]]; then
     FAIL_EXIT "Incorrect action parameters."

  elif [[ "$DB_ACTION" == "to" ]] && [[ -z "$DB_VERSION" ]]; then
     FAIL_EXIT "Missing db migration version parameters."

  else
    SET_DB_VARIABLES
    DB_MIGRATION
  fi
