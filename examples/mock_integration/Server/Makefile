# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0 https://aws.amazon.com/apache-2-0/

TAG?=mainline

CURRENT_DIR:=$(shell pwd)

BUILD_TYPE?=Release
DIST_DIR?=$(shell pwd)/../../../dist
DOCKER_REGISTRY=

.PHONY: clean


build: Dockerfile import-dll
ifneq ($(DOCKER_REGISTRY),)
ifeq ($(BUILD_TYPE), Debug)
	docker build . -f ./Dockerfile_Debug -t $(DOCKER_REGISTRY)/lambda:$(TAG)
else
	docker build . -f ./Dockerfile -t $(DOCKER_REGISTRY)/lambda:$(TAG)
endif
else
ifeq ($(BUILD_TYPE), Debug)
	docker build . -f ./Dockerfile_Debug -t lambda:$(TAG)
else
	docker build . -f ./Dockerfile -t lambda:$(TAG)
endif
endif

upload: build
ifneq ($(DOCKER_REGISTRY),)
	docker push $(DOCKER_REGISTRY)/lambda:$(TAG)
endif

import-dll:
	mkdir -p ./mock_integration_image/src/mock_integration/lib/
	mkdir -p ./mock_integration_image/src/mock_integration/dist/dotnet5.0
	cp -v ../lib/*.dll ./mock_integration_image/src/mock_integration/lib/

	cp -v $(DIST_DIR)/dotnet5.0/*.nupkg ./mock_integration_image/src/mock_integration/dist/dotnet5.0
ifeq ($(BUILD_TYPE), Debug)
	cp -v $(DIST_DIR)/dotnet5.0/*.pdb ./mock_integration_image/src/mock_integration/dist/dotnet5.0
	cp -v ../lib/*.pdb ./mock_integration_image/src/mock_integration/lib/
endif

clean:
	rm lambda.zip
	rm -rf ./mock_integration_image/src/mock_integration/lib