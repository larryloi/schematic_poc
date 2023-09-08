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

#  docker run --rm -it --env-file $(ENV_FILE) -v $(APP_SRC_PATH):$(WORKDIR) -v $(SSHKEY_PATH):$(SSHKEY_PATH) -w $(WORKDIR) $(BASE_IMAGE) bundle install


dst.db.up:
	${INFO} "DB migration Started..."
	docker run --rm -it --env-file .env --network=integration -v $(APP_SRC_PATH):$(WORKDIR) $(IMAGE):$(TAG) /app/scripts/schema-migrate.sh dst up
	${INFO} "DB migration Done..."

dst.db.down:
	${INFO} "DB migration Started..."
	docker run --rm -it --env-file .env -v $(APP_SRC_PATH):$(WORKDIR) $(IMAGE):$(TAG) /app/scripts/schema-migrate.sh dst down
	${INFO} "DB migration Done..."

dst.db.to:
	${INFO} "DB migration Started..."
	docker run --rm -it --env-file .env -v $(APP_SRC_PATH):$(WORKDIR) $(IMAGE):$(TAG) /app/scripts/schema-migrate.sh dst to $(DBVERSION)
	${INFO} "DB migration Done..."

job.deploy:
	${INFO} "Agent Jobs deploy Started..."
	docker run --rm -it --env-file .env -v $(APP_SRC_PATH):$(WORKDIR) $(IMAGE):$(TAG) /app/scripts/agent-jobs-deploy.sh
	${INFO} "Agent Jobs deploy Done..."

src.db.up:
	${INFO} "DB migration Started..."
	docker run --rm -it --env-file .env -v $(APP_SRC_PATH):$(WORKDIR) $(IMAGE):$(TAG) /app/scripts/schema-migrate.sh src up
	${INFO} "DB migration Done..."

src.db.down:
	${INFO} "DB migration Started..."
	docker run --rm -it --env-file .env -v $(APP_SRC_PATH):$(WORKDIR) $(IMAGE):$(TAG) /app/scripts/schema-migrate.sh src down
	${INFO} "DB migration Done..."

src.db.to:
	${INFO} "DB migration Started..."
	docker run --rm -it --env-file .env -v $(APP_SRC_PATH):$(WORKDIR) $(IMAGE):$(TAG) /app/scripts/schema-migrate.sh src to $(DBVERSION)
	${INFO} "DB migration Done..."

src.db.sample:
	${INFO} "Sample data loading Started..."
	docker run --rm -it --env-file .env -v $(SAMPLE_DATA_PATH_LOCAL):$(SAMPLE_DATA_PATH_CT) $(IMAGE):$(TAG) /app/scripts/sample-data-load.sh src
	${INFO} "Sample data loading Done..."


# Cosmetics
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions
INFO := @bash -c '\
  printf $(YELLOW); \
  echo ">>> $$1"; \
  printf $(NC)' SOME_VALUE
