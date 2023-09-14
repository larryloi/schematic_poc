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

        export DB_ADAPTER=${JOB_DB_ADAPTER}
        export DB_USER=${JOB_DB_USER}
        export DB_DATABASE='msdb'
        export DB_PORT=${JOB_DB_PORT}
        export DB_PASSWORD=${JOB_DB_PASSWORD}
        export DB_HOST=${JOB_DB_HOST}
        export FRACTIONAL_SECONDS=${JOB_FRACTIONAL_SECONDS}
        export ENCODING=${JOB_ENCODING}

    }

#============================
# Main
#=============================
#. $RVM_PATH/scripts/rvm


     SET_DB_VARIABLES
     ruby deploy/scripts/agent_jobs_deploy.rb

