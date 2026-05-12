SHELL := /bin/sh

.DEFAULT_GOAL := help

DEST ?= external/LuatOS

SCRIPTS := scripts/check_repo.sh scripts/debug_luatos.sh scripts/download_luatos.sh

.PHONY: help lint test ci fetch-luatos debug

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make lint          - Validate shell scripts' \
		'  make test          - Validate repository plan assets' \
		'  make ci            - Run lint + test' \
		'  make fetch-luatos  - Clone or update LuatOS into DEST (default: external/LuatOS)' \
		'  make debug         - Start OpenOCD + GDB (requires ELF_FILE and OPENOCD_CFG)'

lint:
	@sh -n $(SCRIPTS)

test:
	@./scripts/check_repo.sh

ci: lint test

fetch-luatos:
	@./scripts/download_luatos.sh "$(DEST)"

debug:
	@./scripts/debug_luatos.sh
