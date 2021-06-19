#!/usr/bin/make
# Makefile readme (ru): <http://linux.yaroslavl.ru/docs/prog/gnu_make_3-79_russian_manual.html>
# Makefile readme (en): <https://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents>


include .env

SHELL = /bin/bash
WEB = web
APPS = api
DB = db
TESTS = tests
RUN_COMMAND = docker-compose run --rm
PROJECT = ${PWD##*/}
DJANGO_MANAGE = python manage.py
RUN_TEST_COMMAND = $(SHELL) $(TESTS)/run_tests.sh
# RUN_TEST_COMMAND = $(DJANGO_MANAGE) test

.PHONY : bash build check_upgrade chown clean createsuperuser help init logs \
	makemigrations migrate psql rebuild run shell start startapp stop test

.DEFAULT_GOAL : help

# This will output the help for each task. thanks to
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

bash: ## Start bash into container
	$ $(RUN_COMMAND) $(WEB) /bin/bash

build: ## Build app
	$ docker-compose build $(WEB)

check_upgrade: ## сheck packages version from requirements.txt
	$ $(RUN_COMMAND) $(WEB) python -m pip list --outdated

chown: ## change
	$ sudo chown -R $(USER):$(USER) .

clean: chown ##
	$ rm  -rf $(DB)/data
	$ docker-compose rm -sfv

createsuperuser: ## Start Django shell into container
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) createsuperuser \
	--noinput --username $(DJANGO_SUPERUSER_USERNAME) \
	--email $(DJANGO_SUPERUSER_EMAIL)

help: ## Show this help
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: build makemigrations migrate createsuperuser##
	echo -e "Initializing a project from a template ... \033[32mdone\033[m"

logs: ##
	$ docker-compose logs -f

makemigrations: ## run makemigrations into container
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) makemigrations

migrate: ## run migrate into container
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) migrate

psql: ## Run psql into container (the container web must be running )
	$ docker-compose exec -u postgres $(DB) psql

rebuild: stop chown build ## Rebuild app container
	echo -e "Rebuilding the container image ... \033[32mdone\033[m"

run: ## Start app into container (interactive mode)
	$ docker-compose up

shell: ## Start Django shell into container
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) shell

start: ## Start app into container (daemon mode)
	$ docker-compose up -d

startapp: ## create django app, expample: $ make startapp app=app_name
	$ $(RUN_COMMAND) $(WEB) $(DJANGO_MANAGE) startapp $(app)
	$ $(RUN_COMMAND) $(WEB) mkdir $(TESTS)/$(app)
	$ $(RUN_COMMAND) $(WEB) mv $(app)/tests.py -t $(TESTS)/$(app)
	$ sudo chown -R $(USER):$(USER) $(WEB)

stop: ## Stop app into container (daemon mode)
	$ docker-compose down -t 5

test: ## Run test into container
	$ $(RUN_COMMAND) $(WEB) $(RUN_TEST_COMMAND)
