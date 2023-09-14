#!make
include .env
export $(shell sed 's/=.*//' .env)
include RELEASE
export $(shell sed 's/=.*//' RELEASE)
APP_SRC_PATH := $(realpath ../)
WORKDIR := /app
SAMPLE_DATA_PATH_LOCAL := $(realpath ../src/sample_data)
SAMPLE_DATA_PATH_CT := /app/src/sample_data

# Directory containing the environment files
ENV_DIR := $(realpath ../deploy/jobs/env)

# Temporary file to hold the combined environment variables
COMBINED_ENV_FILE := combined.env

# Concatenate all .env files in the directory into one file
concat_env_files:
	@echo "Concatenating environment files..."
	@rm -f $(COMBINED_ENV_FILE)
	@cat $(ENV_DIR)/*.env > $(COMBINED_ENV_FILE)

clean:
	@echo "Cleaning up..."
	@rm -f $(COMBINED_ENV_FILE)

build: concat_env_files
	docker build -f Dockerfile app -t $(IMAGE):$(TAG)

run: concat_env_files
	docker run -d --env-file $(COMBINED_ENV_FILE) $(IMAGE):$(TAG)

bash: concat_env_files
	docker run --rm -it --env-file $(COMBINED_ENV_FILE) -v $(APP_SRC_PATH):$(WORKDIR) $(IMAGE):$(TAG) /bin/bash

rmi:
	docker rmi $$(docker images|grep ${REPO_PATH}${IMAGE} | grep ${TAG} |head -1 |awk '{print $$3}')


dst.sch.up:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- /app/deploy/scripts/schema_migrate.sh dst up
	${INFO} "Schema migration Done..."

dst.sch.down:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- /app/deploy/scripts/schema_migrate.sh dst down
	${INFO} "Schema migration Done..."

dst.sch.to:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- /app/deploy/scripts/schema_migrate.sh dst to $(DB_VERSION)
	${INFO} "Schema migration Done..."


src.sch.up:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- /app/deploy/scripts/schema_migrate.sh src up
	${INFO} "Schema migration Done..."

src.sch.down:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- /app/deploy/scripts/schema_migrate.sh src down
	${INFO} "Schema migration Done..."

src.sch.to:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- /app/deploy/scripts/schema_migrate.sh src to $(DB_VERSION)
	${INFO} "Schema migration Done..."

src.data.load:
	${INFO} "Sample data loading Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- /app/deploy/scripts/sample_data_load.sh src
	${INFO} "Sample data loading Done..."


job.deploy: concat_env_files
	${INFO} "Agent Jobs deploy Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- /app/deploy/scripts/agent_jobs_deploy.sh
	${INFO} "Agent Jobs deploy Done..."


# Cosmetics
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions
INFO := @bash -c '\
  printf $(YELLOW); \
  echo ">>> $$1"; \
  printf $(NC)' SOME_VALUE
