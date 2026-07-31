MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
ALL_TARGETS := $(shell grep -E -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')
.PHONY: $(ALL_TARGETS)
.DEFAULT_GOAL := help

all: check_for_updates format lint build install ## Check for updates, format, lint, build, and install

actionlint: ## Lint GitHub Actions workflow files
	@echo -e "\033[36m$@\033[0m"
	@./tools/actionlint.sh

build: ## Build Docker image
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh ghcr.io/shakiyam/cmark-gfm

check_for_action_updates: ## Check for GitHub Actions updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_action_updates.sh actions/checkout
	@./tools/check_for_action_updates.sh docker/build-push-action
	@./tools/check_for_action_updates.sh docker/login-action
	@./tools/check_for_action_updates.sh docker/setup-buildx-action
	@./tools/check_for_action_updates.sh docker/setup-qemu-action

check_for_new_release: ## Check for new release
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_new_release.sh github/cmark-gfm "$$(awk -F= '/ENV CMARK_VERSION/{print $$2}' Dockerfile)"

check_for_updates: check_for_action_updates check_for_new_release ## Check for updates to all dependencies

format: shfmt ## Run all formatting

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install cmark-gfm
	@echo -e "\033[36m$@\033[0m"
	@sudo cp cmark-gfm /usr/local/bin/cmark-gfm
	@sudo chmod +x /usr/local/bin/cmark-gfm
	@sudo mkdir -p /usr/local/share/man/man1
	@curl -L# https://raw.githubusercontent.com/github/cmark-gfm/master/man/man1/cmark-gfm.1 | sudo tee /usr/local/share/man/man1/cmark-gfm.1 >/dev/null

lint: actionlint hadolint shellcheck zizmor ## Run all linting

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shellcheck.sh cmark-gfm tools/*.sh

shfmt: ## Format shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shfmt.sh -l -w -i 2 -ci -bn cmark-gfm tools/*.sh

zizmor: ## Lint GitHub Actions workflows for security issues
	@echo -e "\033[36m$@\033[0m"
	@./tools/zizmor.sh .
