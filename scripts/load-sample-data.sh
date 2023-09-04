#!/bin/bash

  FAIL_EXIT()
    {
      echo "=="
      echo "== ${1} "
      echo "=="
      echo "== Usage: bash scripts/load-sample-data.sh <src|dst>"
      echo "== For example: bash scripts/load-sample-data.sh src"
      echo "=="
      exit 1
    }

  SET_DB_VARIABLES()
    {
      SAMPLE_DATA_BASE=sample_data
      export SAMPLE_DATA_PATH="${SAMPLE_DATA_BASE}/${IMAGE}/${DB_TARGET}"
	echo ${SAMPLE_DATA_BASE}
	echo ${DB_TARGET}
      if [[ "$DB_TARGET" == "dst" ]]; then
        export MYSQL_USER=${DST_MYSQL_USER}
        export MYSQL_DATABASE=${DST_MYSQL_DATABASE}
        export MYSQL_PORT=${DST_MYSQL_PORT}
        export MYSQL_PASSWORD=${DST_MYSQL_PASSWORD}
        export MYSQL_HOST=${DST_MYSQL_HOST}
        export FRACTIONAL_SECONDS=${DST_FRACTIONAL_SECONDS}
        export ENCODING=${DST_ENCODING}
      elif [[ "$DB_TARGET" == "src" ]]; then
        export MYSQL_USER=${SRC_MYSQL_USER}
        export MYSQL_DATABASE=${SRC_MYSQL_DATABASE}
        export MYSQL_PORT=${SRC_MYSQL_PORT}
        export MYSQL_PASSWORD=${SRC_MYSQL_PASSWORD}
        export MYSQL_HOST=${SRC_MYSQL_HOST}
        export FRACTIONAL_SECONDS=${SRC_FRACTIONAL_SECONDS}
        export ENCODING=${SRC_ENCODING}
      fi
    }

#============================
# Main
#=============================
#. $RVM_PATH/scripts/rvm
export DB_TARGET=$1

  if [[ -z "$DB_TARGET" ]] ; then
     FAIL_EXIT "Missing parameters. "
  else
     SET_DB_VARIABLES
     ruby scripts/load-sample-data.rb
  fi
