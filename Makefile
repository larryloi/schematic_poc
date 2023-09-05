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
