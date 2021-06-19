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

.PHONY : help shell run start stop build test rebuild chown psql migrate makemigrations check_upgrade
.DEFAULT_GOAL : help

# This will output the help for each task. thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

help: ## Show this help
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

shell: ## Start Django shell into container
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) shell

bash: ## Start bash into container
	$ $(RUN_COMMAND) $(WEB) /bin/bash

run: ## Start app into container (interactive mode)
	$ docker-compose up

start: ## Start app into container (daemon mode)
	$ docker-compose up -d

stop: ## Stop app into container (daemon mode)
	$ docker-compose down

build: ## Build app
	$ docker-compose build $(WEB)

test: ## Run test into container
	$ $(RUN_COMMAND) $(WEB) $(RUN_TEST_COMMAND)

rebuild: ## Rebuild app container
	$ docker-compose down -t 5
	$ sudo chown -R $(USER):$(USER) .
	$ docker-compose up --build $(WEB)

chown: ## change
	$ sudo chown -R $(USER):$(USER) .

psql: ## Run psql into container (the container must be running )
	$ docker-compose exec -u postgres $(DB) psql

migrate: ## run migrate into container
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) migrate

makemigrations: ## run makemigrations into container
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) makemigrations

check_upgrade: ## сheck packages version from requirements.txt
	$ $(RUN_COMMAND) $(WEB) python -m pip list --outdated

startapp: ## create django app, expample: $ make startapp app=app_name
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) startapp $(app) $(APPS)/$(app)
	$ sudo chown -R $(USER):$(USER) $(WEB)


init: build startproject##
	echo "init project"

