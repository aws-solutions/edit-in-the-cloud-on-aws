# This file was heavily influenced by the AWS EKS Reference Architecture
# https://github.com/aws-samples/amazon-eks-refarch-cloudformation

CUSTOM_FILE ?= custom.mk
ifneq ("$(wildcard $(CUSTOM_FILE))","")
	include $(CUSTOM_FILE)
endif

STACKPREFIX ?= 'cfn'
REGION ?= 'us-east-1'
PROFILE ?= 'default'
CFN_BUCKET ?= 'adobe-poc-cfn-ncal'
CFN_KEY ?= 'cfn-repo'
CFN_TEMPLATE ?= 'templates/cloud-video-editing-master-with-FSX.yaml'
PARAM_FILE ?= 'ci/cloud-video-editing-master-with-FSX.json'
AWS_PROFILE ?= $(PROFILE)
STACK_NAME ?= 'cfn-cloud-video-editing-stack-v1'
TEMPLATENAME ?= $(CFN_TEMPLATE)
ROOT ?= $(shell pwd)
TEMPLATE_URL ?= 'https://$(CFN_BUCKET).s3.$(REGION).amazonaws.com/$(CFN_KEY)/$(CFN_TEMPLATE)'
CAPABILITIES=CAPABILITY_IAM CAPABILITY_NAMED_IAM
TIMEOUT_IN_MINS ?= '120'

ndef = $(if $(value $(1)),,$(error $(1) not set))

checkenv:
    @echo = "Checking Environment variables ..."
    $(call ndef,PROFILE)
    $(call ndef,REGION)
    $(call ndef,CFN_BUCKET)
    $(call ndef,CFN_KEY)
    $(call ndef,CFN_TEMPLATE)
    $(call ndef,PARAM_FILE)
    $(call ndef,AWS_PROFILE)
    $(call ndef,STACK_NAME)
    @echo = "Env. Check complete!"

.PHONY: prepare-boto3 # Prepare boto3 Layer Archive
prepare-boto3: checkenv boto3-layer.zip

boto3-layer.zip:
	@printf "\n>>>Prepping boto3-layer archive<<<\n\n"

	@echo "Removing Package dir:"
	@rm -rf package

	if [ -f ./sgw/boto3-layer.zip ]; then \
		rm -f ./sgw/boto3-layer.zip; \
	fi

	@echo "Creating staging dir."
	mkdir -p package/python

	@echo "Building boto3-layer package ..." 
	cd package && python3 -m venv .venv; \
	source ./.venv/bin/activate && pip3 install --quiet boto3 && pip3 install --quiet crhelper; \

	@echo "Creating the boto3-layer archive"; \
	cd package && cp -r .venv/lib/python3.7/site-packages/* python/; \
	zip -r9 -q '../sgw/boto3-layer.zip' . -i 'python/*'

	@echo "Built boto3 package and copied!"

	@echo "Cleaning up..."
	cd ..
	rm -rf package

	@printf "\n>>>All completed on the boto3 layer prep!<<<\n\n"

.PHONY: upload-files # Upload Files
upload-files: checkenv prepare-boto3
	@printf "\n>>>Upload Files to S3 <<<\n\n"
	@echo "upload s3 files to: ${CFN_BUCKET}/${CFN_KEY}"

	aws s3 sync \
		./ s3://$(CFN_BUCKET)/$(CFN_KEY) \
		--profile $(AWS_PROFILE) \
		--region $(REGION) \
		--exclude "*" \
		--include "submodules/quickstart-aws-vpc/*" \
		--include "submodules/quickstart-microsoft-activedirectory/*" \
		--include "submodules/quickstart-microsoft-utilities/*" \
		--include "templates/*" \
		--include "sgw/*" \
		--include "scripts/*"
  
	@printf "\n>>>Upload files to S3 completed!<<<\n\n"

.PHONY: validate-template # Validate Cloudformation Template via URL
validate-template: checkenv upload-files
	@printf "\n>>>Validating Template URL now <<<\n\n"
	@echo [validate-template] $(STACKPREFIX)-$(STACK_NAME)-$(REGION)
	@aws --region=$(REGION) cloudformation --profile $(PROFILE) \
	validate-template --template-url $(TEMPLATE_URL)
	@printf "\n\n>>>Validating Template URL completed! <<<\n\n"

.PHONY: create-stack # Create Cloudformation Stack
create-stack: checkenv upload-files
	@printf "\n>>>Creating CloudFormation Stack ... <<<\n\n"
	@echo = [create-stack] $(STACKPREFIX)-$(STACK_NAME)-$(REGION)
	@aws cloudformation --profile $(PROFILE) \
	create-stack --template-url $(TEMPLATE_URL) \
	--stack-name $(STACKPREFIX)-$(STACK_NAME)-$(REGION) --capabilities $(CAPABILITIES) \
	--region $(REGION) --parameters file://$(PARAM_FILE) --disable-rollback \
	--timeout $(TIMEOUT_IN_MINS)
	@printf "\n>>> Completed the Creation of the CloudFormation Stack!<<<\n\n"

.PHONY: describe-stack # Describe Cloudformation Stack Status
describe-stack: checkenv
	@printf "\n>>>Describing the CloudFormation Stack now<<<\n\n"
	@echo = [describe-stack] $(STACKPREFIX)-$(STACK_NAME)-$(REGION)
	@aws cloudformation --region=$(REGION) --profile $(PROFILE) describe-stack-events \
	--query 'StackEvents[*].[Timestamp,ResourceStatus,LogicalResourceId,ResourceType]' --output text \
	--stack-name $(STACKPREFIX)-$(STACK_NAME)-$(REGION) | \
	sort -k4r | column -t | \
	sed -E "s/([A-Z_]+_COMPLETE[A-Z_]*)/`printf "\e[0;32m"`\1`printf "\e[0m"`/g" | \
	sed -E "s/([A-Z_]+_IN_PROGRESS[A-Z_]*)/`printf "\e[0;33m"`\1`printf "\e[0m"`/g" | \
	sed -E "s/([A-Z_]*ROLLBACK[A-Z_]*)/`printf "\e[0;31m"`\1`printf "\e[0m"`/g" | \
	sed -E "s/([A-Z_]*FAILED[A-Z_]*)/`printf "\e[0m\e[41m"`\1`printf "\e[0m"`/g" | \
	sed -E "s/(AWS::CloudFormation::Stack)/`printf "\e[4m"`\1`printf "\e[0m"`/g"
	@printf "\n>>> Completed the Description of the CloudFormation Stack!<<<\n\n"

.PHONY: delete-stack # Delete Cloudformation Stack Including buckets and logs
delete-stack: checkenv
	@printf "\n>>>Deleting CloudFormation Stack ... <<<\n\n"
	@echo = [delete-stack] $(STACKPREFIX)-$(STACK_NAME)-$(REGION)
	@aws cloudformation --region $(REGION) --profile $(PROFILE) \
	delete-stack --stack-name $(STACKPREFIX)-$(STACK_NAME)-$(REGION)
	@printf "\n>>> Completed the Deletion of the CloudFormation Stack!<<<\n\n"

.PHONY: help # Generate list of targets with descriptions                                       
help:
	@printf "\n>>>>>>>>>>>>> Makefile Help: list of targets <<<<<<<<<<<\n\n"
	@grep '^.PHONY: .* #' $(MAKEFILE_LIST) | sed 's/\.PHONY: \(.*\) \(.*\)/\1 \2/' | expand -t20
	@printf "\n>>>>>>>> End of Makefile Help: list of targets <<<<<<<<<\n\n"
