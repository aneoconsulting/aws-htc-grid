# Copyright 2021-2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use this file
# except in compliance with the License. A copy of the License is located at
#
# http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied. See the
# License for the specific language governing permissions and limitations under the License


BUILD_DIR:=.build
export TAG
export REGION?=eu-west-1

YAML_SRC:=encrypted_s3_buckets.yaml

all: $(BUILD_DIR)/grid_init/init-grid-$(TAG)

.PHONY: clean delete init

$(BUILD_DIR)/grid_init:
	mkdir -p $(BUILD_DIR)/grid_init
	
$(BUILD_DIR)/grid_init/tag.$(TAG):
	@touch $(BUILD_DIR)/grid_init/tag.$(TAG)
	
$(BUILD_DIR)/grid_init/init-grid-$(TAG): $(BUILD_DIR)/grid_init/tag.$(TAG) $(YAML_SRC)
	aws cloudformation create-stack --stack-name $(TAG) --region $(REGION) --template-body file://$(YAML_SRC) --parameters ParameterKey=BucketTag,ParameterValue=$(TAG)
	@echo "Waiting for cloud formation successful deployment"
	@aws cloudformation wait stack-create-complete --stack-name $(TAG) --region $(REGION)
	@touch $(BUILD_DIR)/grid_init/init-grid-$(TAG)
	aws cloudformation describe-stacks --stack-name $(TAG) --region $(REGION) --query 'Stacks[0]'
	
$(TAG)-workload-bucket: $(BUILD_DIR)/grid_init/init-grid-$(TAG)-workload-bucket

init: $(BUILD_DIR)/grid_init

delete:
	aws cloudformation delete-stack --stack-name $(TAG) --region $(REGION)
	aws cloudformation wait stack-delete-complete --stack-name $(shell aws cloudformation describe-stacks --region $(REGION) --stack-name $(TAG) --query 'Stacks[0].StackId' --output text) --region $(REGION)

	
clean:
	rm -rf $(BUILD_DIR)/tag.*
	