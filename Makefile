SHELL := /bin/bash
current_dir = $(shell pwd)

.PHONY: help

help :
	@echo "install-python-dependencies		: install python dependencies required for infra using nexus as index-url"
	@echo "run-unit-tests                   : run all python unit tests"
	@echo "run-container-unit-tests        : run all the docker container structure tests"
	@echo "run-post-deploy-tests           : run all the post-deploy functional tests"
	@echo "build-and-push-images-to-ecr    : build all images in dockerfile directory and push to respective ECR."

	@echo "deploy-infra                    : deploy-infra in the account"
	@echo "destroy-infra                   : deploy-infra in the account"

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# \
	Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

install-python-dependencies:
	no_proxy=ftl.uk.fid-intl.com python -m pip install --upgrade --force-reinstall -r requirements.txt \
	-i https://ftl.uk.fid-intl.com:8443/repository/pypi-all/simple --cert app/certificates/nexus_pypi.pem

run-unit-tests:
	GIT_COMMIT_SHORT="latest" PYTHONPATH="${current_dir}/infra" ${current_dir}/infra/tests/run_unit_tests.py -vv

run-container-unit-tests:
	GIT_COMMIT_SHORT="latest" PYTHONPATH="${current_dir}/infra" ${current_dir}/infra/tests/run_pre_deploy_tests.py

run-post-deploy-tests:
	GIT_COMMIT_SHORT="latest" PYTHONPATH="${current_dir}/infra" ${current_dir}/infra/tests/run_post_deploy_tests.py -s

build-and-push-images-to-ecr:
	GIT_COMMIT_SHORT="latest" PYTHONPATH="${current_dir}/infra" ${current_dir}/infra/scripts/infra_main.py -a build_image

deploy-infra:
	GIT_COMMIT_SHORT="latest" PYTHONPATH="${current_dir}/infra" ${current_dir}/infra/scripts/infra_main.py -a deploy

destroy-infra:
	GIT_COMMIT_SHORT="latest" PYTHONPATH="${current_dir}/infra" ${current_dir}/infra/scripts/infra_main.py -a destroy