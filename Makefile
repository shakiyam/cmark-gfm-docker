MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.SUFFIXES:

ALL_TARGETS := $(shell egrep -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')

.PHONY: $(ALL_TARGETS)

all: check_for_updates hadolint shellcheck shfmt build install ## Check for updates, lint, build, and install
	@:

build: ## Build an image from a Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh docker.io/shakiyam/cmark-gfm

check_for_image_updates: ## Check for updates to dependencies
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_image_updates.sh "$(shell awk -e '/FROM/{print $$2}' Dockerfile)" docker.io/alpine:latest

check_for_new_release: ## Check for updates to dependencies
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_new_release.sh "$(shell awk -F= -e '/ENV CMARK_VERSION/{print $$2}' Dockerfile)" github/cmark-gfm

check_for_updates: check_for_image_updates check_for_new_release ## Check for updates to dependencies
	@:

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile

install: ## Install cmark-gfm
	@echo -e "\033[36m$@\033[0m"
	@sudo cp cmark-gfm /usr/local/bin/cmark-gfm
	@sudo chmod +x /usr/local/bin/cmark-gfm
	@curl -L# https://raw.githubusercontent.com/github/cmark-gfm/master/man/man1/cmark-gfm.1 | sudo tee /usr/local/share/man/man1/cmark-gfm.1 >/dev/null

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shellcheck.sh cmark-gfm tools/*.sh

shfmt: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shfmt.sh -l -d -i 2 -ci -bn cmark-gfm tools/*.sh
