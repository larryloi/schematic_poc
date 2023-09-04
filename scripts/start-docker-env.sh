#!/bin/bash

  HILN()
    {
      echo -e "\n\e[33m>>> ${1}\e[0m"
    }

#HILN "Creating network ...\n"
#docker network create --driver bridge --subnet 192.168.19.0/20 --gateway 192.168.19.1 platform_integration || true
#docker network create --driver bridge platform_integration || true

#docker volume create --driver local --name opsta-db || true
  START_SRC()
    {
      HILN "Starting up source database ...\n"
      docker-compose up -d src-db

      #docker-compose up -d opsta-db

      HILN "Running DB migration for source database ...\n"
      make src.db.up

      HILN "Loading Sample data into source database ...\n"
      make src.db.load
    }

  START_DST()
    {
      HILN "Running DB migration for destination database ...\n"
      make dst.db.up

      ### For migrating particular db version; please specify like this
      ### make dst.db.to DBVERSION=202009211038
    }

  START_APP()
    {
      HILN "Starting up archive service ...\n"
      docker-compose up -d app

      HILN "Running containers.\n"; docker-compose ps; HILN "Docker volumes.\n"; docker volume ls
    }

  BUILD_IMAGE()
    {
      HILN "Removeing archiver image ...\n"
      make rmi
      HILN "Building archiver image ...\n"
      make build
    }

############
### MAIN ###
############

  #BUILD_IMAGE
  #START_SRC
  #START_DST
  START_APP
