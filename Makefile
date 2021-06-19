#!/usr/bin/make
# Makefile readme (ru): <http://linux.yaroslavl.ru/docs/prog/gnu_make_3-79_russian_manual.html>
# Makefile readme (en): <https://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents>


include .env

SHELL = /bin/bash
WEB = web
APPS = api
DB = db
RUN_COMMAND = docker-compose run --rm
PROJECT = ${PWD##*/}
DJANGO_MANAGE = python manage.py
RUN_TEST_COMMAND = $(SHELL) tests/run_tests.sh
# RUN_TEST_COMMAND = $(DJANGO_MANAGE) test

.PHONY : bash build check_upgrade chown help makemigrations migrate psql rebuild run \
shell start startapp stop test

.DEFAULT_GOAL : help

# This will output the help for each task. thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
bash: ## Start bash into container
	$ $(RUN_COMMAND) $(WEB) /bin/bash

build: ## Build app
	$ docker-compose build $(WEB)

check_upgrade: ## сheck packages version from requirements.txt
	$ $(RUN_COMMAND) $(WEB) python -m pip list --outdated

chown: ## change
	$ sudo chown -R $(USER):$(USER) .

help: ## Show this help
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

makemigrations: ## run makemigrations into container
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) makemigrations


migrate: ## run migrate into container
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) migrate

psql: ## Run psql into container (the container must be running )
	$ docker-compose exec -u postgres $(DB) psql

rebuild: ## Rebuild app container
	$ docker-compose down -t 5
	$ sudo chown -R $(USER):$(USER) .
	$ docker-compose up --build $(WEB)

run: ## Start app into container (interactive mode)
	$ docker-compose up

shell: ## Start Django shell into container
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) shell

start: ## Start app into container (daemon mode)
	$ docker-compose up -d

startapp: ## create django app, expample: $ make startapp app=app_name
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) startapp $(app) $(APPS)/$(app)
	$ sudo chown -R $(USER):$(USER) $(WEB)

stop: ## Stop app into container (daemon mode)
	$ docker-compose down

test: ## Run test into container
	$ $(RUN_COMMAND) $(WEB) $(RUN_TEST_COMMAND)

#init: build startproject##
#	echo "init project"

