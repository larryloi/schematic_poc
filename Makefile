#!make
include .env
export $(shell sed 's/=.*//' .env)
include RELEASE
export $(shell sed 's/=.*//' RELEASE)
APP_SRC_PATH := $(realpath ../)
WORKDIR := /app
SAMPLE_DATA_PATH_LOCAL := $(realpath ../sample_data)
SAMPLE_DATA_PATH_CT := /app/sample_data

build:
	docker build -f Dockerfile app -t $(IMAGE):$(TAG)

run:
	docker run -d --env-file .env $(IMAGE):$(TAG)

bash:
	docker run --rm -it --env-file .env -v $(APP_SRC_PATH):$(WORKDIR) -v $(SAMPLE_DATA_PATH_LOCAL):$(SAMPLE_DATA_PATH_CT) $(IMAGE):$(TAG) /bin/bash

rmi:
	docker rmi $$(docker images|grep ${REPO_PATH}${IMAGE} | grep ${TAG} |head -1 |awk '{print $$3}')


dst.sch.up:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- /app/scripts/schema-migrate.sh dst up
	${INFO} "Schema migration Done..."

dst.sch.down:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- /app/scripts/schema-migrate.sh dst down
	${INFO} "Schema migration Done..."

dst.sch.to:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- /app/scripts/schema-migrate.sh dst to $(DBVERSION)
	${INFO} "Schema migration Done..."


src.sch.up:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- /app/scripts/schema-migrate.sh src up
	${INFO} "Schema migration Done..."

src.sch.down:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- /app/scripts/schema-migrate.sh src down
	${INFO} "Schema migration Done..."

src.sch.to:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- /app/scripts/schema-migrate.sh src to $(DBVERSION)
	${INFO} "Schema migration Done..."

src.data.load:
	${INFO} "Sample data loading Started..."
	docker-compose run --rm app /app/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- /app/scripts/sample-data-load.sh src
	${INFO} "Sample data loading Done..."


job.deploy:
	${INFO} "Agent Jobs deploy Started..."
	docker-compose run --rm app /app/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- /app/scripts/agent-jobs-deploy.sh
	${INFO} "Agent Jobs deploy Done..."


# Cosmetics
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions
INFO := @bash -c '\
  printf $(YELLOW); \
  echo ">>> $$1"; \
  printf $(NC)' SOME_VALUE
