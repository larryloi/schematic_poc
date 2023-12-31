#!make
  include docker.env
  export $(shell sed 's/=.*//' docker.env)
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


help:
	@grep '^[^#[:space:]].*:' Makefile


# Check if JOBS_DIR exists and is not empty
check_jobs_dir:
	${INFO} "Checking job config paths ..."
	@if [ ! -d "$(JOBS_DIR)" ]; then \
		echo "Error: JOBS_DIR $(JOBS_DIR) does not exist"; \
		exit 1; \
	fi
	@if [ -z "$(shell ls -A $(JOBS_DIR))" ]; then \
		echo "Error: JOBS_DIR $(JOBS_DIR) is empty"; \
		exit 1; \
	fi

# Concatenate all .env files in the directory into one file
concat_env_files: check_jobs_dir
	${INFO} "Concatenating environment files..."
	@rm -f $(COMBINED_ENV_FILE)
	@find $(JOBS_DIR) -name '*.env' -exec cat {} \; > $(COMBINED_ENV_FILE)

#: Clean up combined.env
clean:
	@echo "Cleaning up..."
	@rm -f $(COMBINED_ENV_FILE)

#: Build Docker images
build:
	${INFO} "Building docker images."
	docker build -f Dockerfile app -t $(IMAGE):$(TAG)

#: Run docker container
run: concat_env_files
	docker run -d --env-file $(COMBINED_ENV_FILE) $(IMAGE):$(TAG)

#: Login to container
bash: concat_env_files
	${INFO} "Login to container."
#	docker run --rm -it --env-file $(COMBINED_ENV_FILE) -v $(APP_SRC_PATH):$(WORKDIR) $(IMAGE):$(TAG) /bin/bash
	docker-compose exec -u ds app /bin/bash

#: List docker images
images:
	${INFO} "Listing docker images."
	docker images

#: Remove docker images
rmi:
	${INFO} "Removing docker images."
	docker rmi $$(docker images|grep ${REPO_PATH}${IMAGE} | grep ${TAG} |head -1 |awk '{print $$3}')

#: List container
ps:
	${INFO} "List container processes."
	docker-compose ps

#: Bring up all containers
all.up:
	docker network create --driver bridge integration || true
	${INFO} "Bring up all Containers "
	docker-compose up -d db
	docker-compose exec db /mssql-init/wait-for-it.sh db:1433 -t 60 -- /mssql-init/configure-db.sh
	docker-compose up -d app

#: Turn all containers down
all.down:
	${INFO} "Turn all containers down"
	docker-compose down -v
	docker-compose ps

#: Bring up app containers
app.up:
	docker network create --driver bridge integration || true
	${INFO} "Turn all containers down"
	docker-compose up -d app
	docker-compose ps

#: Turn app containers down
app.down:
	${INFO} "Turn all containers down"
	docker-compose rm -sf app
	docker-compose ps

# Cosmetics
 YELLOW := "\e[1;33m"
 NC := "\e[0m"

# Shell Functions
 INFO := @bash -c '\
  printf $(YELLOW); \
  echo ">>> $$1"; \
  printf $(NC)' SOME_VALUE
