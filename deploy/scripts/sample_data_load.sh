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
      SAMPLE_DATA_BASE=src/sample_data
      export SAMPLE_DATA_PATH="${SAMPLE_DATA_BASE}/${IMAGE}/${DB_TARGET}"

echo ${SAMPLE_DATA_PATH}

      if [[ "$DB_TARGET" == "dst" ]]; then
        export DB_ADAPTER=${DST_DB_ADAPTER}
        export DB_USER=${DST_DB_USER}
        export DB_DATABASE=${DST_DB_NAME}
        export DB_PORT=${DST_DB_PORT}
        export DB_PASSWORD=${DST_DB_PASSWORD}
        export DB_HOST=${DST_DB_HOST}
        export FRACTIONAL_SECONDS=${DST_FRACTIONAL_SECONDS}
        export ENCODING=${DST_ENCODING}
      elif [[ "$DB_TARGET" == "src" ]]; then
        export DB_ADAPTER=${SRC_DB_ADAPTER}
        export DB_USER=${SRC_DB_USER}
        export DB_DATABASE=${SRC_DB_NAME}
        export DB_PORT=${SRC_DB_PORT}
        export DB_PASSWORD=${SRC_DB_PASSWORD}
        export DB_HOST=${SRC_DB_HOST}
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
     ruby deploy/scripts/sample_data_load.rb ${SAMPLE_DATA_PATH}
  fi
