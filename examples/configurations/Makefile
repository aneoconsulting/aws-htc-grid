# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0 https://aws.amazon.com/apache-2-0/

TAG=mainline
GENERATED?=generated
BUCKET_NAME=
FILE_HANDLER=
FUNCTION_HANDLER=
TASKS_TABLE_SERVICE=
REGION=
ACCOUNT_ID=
BUCKET_NAME=
#BUCKET_NAME=$(shell aws cloudformation describe-stacks --stack-name $(TAG) --region $(REGION) --query 'Stacks[0].Outputs[0].OutputValue' --output text)

generated-c++: grid_config.json.tpl
	mkdir -p $(GENERATED) && cat grid_config.json.tpl | sed "s/{{tasks_status_table_service}}/$(TASKS_TABLE_SERVICE)/;s/{{region}}/$(REGION)/;s/{{workload_bucket_name}}/$(BUCKET_NAME)/;s/{{image_tag}}/$(TAG)/;s/{{account_id}}/${ACCOUNT_ID}/" > $(GENERATED)/grid_config.json

generated-s3-c++: custom_runtime_s3_grid_config.json.tpl
	mkdir -p $(GENERATED) && cat custom_runtime_s3_grid_config.json.tpl | sed "s/{{tasks_status_table_service}}/$(TASKS_TABLE_SERVICE)/;s/{{region}}/$(REGION)/;s/{{workload_bucket_name}}/$(BUCKET_NAME)/;s/{{image_tag}}/$(TAG)/;s/{{account_id}}/${ACCOUNT_ID}/" > $(GENERATED)/custom_runtime_s3_grid_config.json

generated-python: python_runtime_grid_config.json.tpl
	mkdir -p $(GENERATED) && cat python_runtime_grid_config.json.tpl | sed "s/{{tasks_status_table_service}}/$(TASKS_TABLE_SERVICE)/;s/{{python_file_handler}}/$(FILE_HANDLER)/;s/{{python_function_handler}}/$(FUNCTION_HANDLER)/;s/{{region}}/$(REGION)/;s/{{workload_bucket_name}}/$(BUCKET_NAME)/;s/{{image_tag}}/$(TAG)/;s/{{account_id}}/${ACCOUNT_ID}/" > $(GENERATED)/python_runtime_grid_config.json

generated-dotnet5.0: dotnet5.0_runtime_grid_config.json.tpl
	mkdir -p $(GENERATED) && cat dotnet5.0_runtime_grid_config.json.tpl | sed "s/{{tasks_status_table_service}}/$(TASKS_TABLE_SERVICE)/;s/{{dotnet50_file_handler}}/$(FILE_HANDLER)/;s/{{region}}/$(REGION)/;s/{{workload_bucket_name}}/$(BUCKET_NAME)/;s/{{image_tag}}/$(TAG)/;s/{{account_id}}/${ACCOUNT_ID}/" > $(GENERATED)/dotnet5.0_runtime_grid_config.json

clean:
	rm -rf $(GENERATED)