#!make
include .env
export $(shell sed 's/=.*//' .env)
include RELEASE
export $(shell sed 's/=.*//' RELEASE)
APP_SRC_PATH := $(realpath ../)
WORKDIR := /app
SAMPLE_DATA_PATH_LOCAL := $(realpath ../src/sample_data)
SAMPLE_DATA_PATH_CT := /app/src/sample_data
MIGRATION_PATH_SRC := /app/src/db/migrations/src
MIGRATION_PATH_DST := /app/src/db/migrations/dst


# Directory containing the job directories
JOBS_DIR := $(realpath ../deploy/jobs)

# Temporary file to hold the combined environment variables
COMBINED_ENV_FILE := combined.env

# Concatenate all .env files in the directory into one file
concat_env_files:
	@echo "Concatenating environment files..."
	@rm -f $(COMBINED_ENV_FILE)
	@find $(JOBS_DIR) -name '*.env' -exec cat {} \; > $(COMBINED_ENV_FILE)

clean:
	@echo "Cleaning up..."
	@rm -f $(COMBINED_ENV_FILE)

build: concat_env_files
	docker build -f Dockerfile app -t $(IMAGE):$(TAG)

run: concat_env_files
	docker run -d --env-file $(COMBINED_ENV_FILE) $(IMAGE):$(TAG)

bash: concat_env_files
#	docker run --rm -it --env-file $(COMBINED_ENV_FILE) -v $(APP_SRC_PATH):$(WORKDIR) $(IMAGE):$(TAG) /bin/bash
	docker-compose run --rm app 

rmi:
	docker rmi $$(docker images|grep ${REPO_PATH}${IMAGE} | grep ${TAG} |head -1 |awk '{print $$3}')



########
src.sch.up:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- rake db:migrate:up DB_USER=$(SRC_DB_USER) DB_NAME=$(SRC_DB_NAME) DB_PORT=$(SRC_DB_PORT) DB_PASSWORD=$(SRC_DB_PASSWORD) DB_HOST=$(SRC_DB_HOST) SCHEMA_TABLE=$(SRC_SCHEMA_TABLE) DB_ADAPTER=$(SRC_DB_ADAPTER) MIGRATION_PATH=$(MIGRATION_PATH_SRC) DB_SCHEMA=$(SRC_DB_SCHEMA)
	${INFO} "Schema migration Done..."

src.sch.down:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- rake db:migrate:down DB_USER=$(SRC_DB_USER) DB_NAME=$(SRC_DB_NAME) DB_PORT=$(SRC_DB_PORT) DB_PASSWORD=$(SRC_DB_PASSWORD) DB_HOST=$(SRC_DB_HOST) SCHEMA_TABLE=$(SRC_SCHEMA_TABLE) DB_ADAPTER=$(SRC_DB_ADAPTER) MIGRATION_PATH=$(MIGRATION_PATH_SRC) DB_SCHEMA=$(SRC_DB_SCHEMA)
	${INFO} "Schema migration Done..."

src.sch.to:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- rake db:migrate:to DB_USER=$(SRC_DB_USER) DB_NAME=$(SRC_DB_NAME) DB_PORT=$(SRC_DB_PORT) DB_PASSWORD=$(SRC_DB_PASSWORD) DB_HOST=$(SRC_DB_HOST) SCHEMA_TABLE=$(SRC_SCHEMA_TABLE) DB_ADAPTER=$(SRC_DB_ADAPTER) MIGRATION_PATH=$(MIGRATION_PATH_SRC) VERSION=$(DB_VERSION) DB_SCHEMA=$(SRC_DB_SCHEMA)
	${INFO} "Schema migration Done..."

src.data.load: concat_env_files
	${INFO} "Sample data loading Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(SRC_DB_HOST):1433 -t 60 -- ruby /app/deploy/scripts/sample_data_load.rb /app/src/sample_data/schematic/src
	${INFO} "Sample data loading Done..."



########
dst.sch.up:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- rake db:migrate:up DB_USER=$(DST_DB_USER) DB_NAME=$(DST_DB_NAME) DB_PORT=$(DST_DB_PORT) DB_PASSWORD=$(DST_DB_PASSWORD) DB_HOST=$(DST_DB_HOST) SCHEMA_TABLE=$(DST_SCHEMA_TABLE) DB_ADAPTER=$(DST_DB_ADAPTER) MIGRATION_PATH=$(MIGRATION_PATH_DST) DB_SCHEMA=$(DST_DB_SCHEMA)
	${INFO} "Schema migration Done..."

dst.sch.down:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- rake db:migrate:down DB_USER=$(DST_DB_USER) DB_NAME=$(DST_DB_NAME) DB_PORT=$(DST_DB_PORT) DB_PASSWORD=$(DST_DB_PASSWORD) DB_HOST=$(DST_DB_HOST) SCHEMA_TABLE=$(DST_SCHEMA_TABLE) DB_ADAPTER=$(DST_DB_ADAPTER) MIGRATION_PATH=$(MIGRATION_PATH_DST) DB_SCHEMA=$(DST_DB_SCHEMA)
	${INFO} "Schema migration Done..."

dst.sch.to:
	${INFO} "Schema migration Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- rake db:migrate:to DB_USER=$(DST_DB_USER) DB_NAME=$(DST_DB_NAME) DB_PORT=$(DST_DB_PORT) DB_PASSWORD=$(DST_DB_PASSWORD) DB_HOST=$(DST_DB_HOST) SCHEMA_TABLE=$(DST_SCHEMA_TABLE) DB_ADAPTER=$(DST_DB_ADAPTER) MIGRATION_PATH=$(MIGRATION_PATH_DST) VERSION=$(DB_VERSION) DB_SCHEMA=$(DST_DB_SCHEMA)
	${INFO} "Schema migration Done..."

dst.sp.deploy:
	${INFO} "Stored Procedure Create Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- ruby /app/deploy/scripts/stored_procedure_deploy.rb
	${INFO} "Stored Procedure Create Done..."

dst.job.deploy: concat_env_files
	${INFO} "Agent Jobs deploy Started..."
	docker-compose run --rm app /app/deploy/scripts/wait-for-it.sh $(DST_DB_HOST):1433 -t 60 -- ruby /app/deploy/scripts/agent_jobs_deploy.rb
	${INFO} "Agent Jobs deploy Done..."








# Cosmetics
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions
INFO := @bash -c '\
  printf $(YELLOW); \
  echo ">>> $$1"; \
  printf $(NC)' SOME_VALUE
