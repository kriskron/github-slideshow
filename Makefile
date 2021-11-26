DEPLOY_ENV ?= undefined
include deploy_envs/$(DEPLOY_ENV)-envs.mak
.PHONY: all
all: init plan apply

%_environment: deploy_envs/%/terraform.tfvars env_symlinks
	@echo "********************************************************"
	@echo "       Configuring for $* deployment"
	@echo "********************************************************"
undefined_environment:
	@echo "********************************************************"
	@echo "*       Please set the DEPLOY_ENV variable             *"
	@echo "********************************************************"
	@exit -1
env_symlinks: deploy_envs/${DEPLOY_ENV}/provider.tf
	@echo "********************************************************"
	@echo "     Cleaning up Symlinks from previous deployment"
	@echo "********************************************************"
	find . -type l -maxdepth 1 -print -exec rm {} \;
	for tffile in deploy_envs/${DEPLOY_ENV}/*.tf; \
	do \
		ln -s $${tffile} $$(basename $${tffile}); \
	done
init: ${DEPLOY_ENV}_environment
	rm -rf .terraform/modules/
	terraform init -reconfigure \
	    -backend-config="resource_group_name=${resource_group_name}" \
		-backend-config="storage_account_name=${storage_account_name}" \
		-backend-config="container_name=${container_name}" \
		-backend-config="sas_token=${sas_token}" \
		-backend-config="key=${key}"
  
