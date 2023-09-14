#!/bin/bash

  FAIL_EXIT()
    {
      echo "=="
      echo "== ${1} "
      echo "=="
      echo "== Usage: bash deploy/scripts/seed_data_load"
      echo "== For example: bash scripts/seed_data_load"
      echo "=="
      exit 1
    }

  SET_DB_VARIABLES()
    {

        export DB_ADAPTER=${DST_DB_ADAPTER}
        export DB_USER=${DST_DB_USER}
        export DB_DATABASE=${DST_DB_NAME}
        export DB_PORT=${DST_DB_PORT}
        export DB_PASSWORD=${DST_DB_PASSWORD}
        export DB_HOST=${DST_DB_HOST}
        export FRACTIONAL_SECONDS=${DST_FRACTIONAL_SECONDS}
        export ENCODING=${DST_ENCODING}

    }

#============================
# Main
#=============================
#. $RVM_PATH/scripts/rvm


     SET_DB_VARIABLES
     ruby deploy/scripts/seed_data_load.rb

