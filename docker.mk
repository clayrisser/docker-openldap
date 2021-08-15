# File: /docker.mk
# Project: docker-openldap
# File Created: 24-06-2021 04:03:49
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 14-07-2021 21:41:11
# Modified By: Clay Risser <email@clayrisser.com>
# -----
# Silicon Hills LLC (c) Copyright 2021
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TAG ?= latest
MAJOR := $(shell echo $(VERSION) | cut -d. -f1)
MINOR := $(shell echo $(VERSION) | cut -d. -f2)
PATCH := $(shell echo $(VERSION) | cut -d. -f3)

export PLATFORM := $(shell node -e "process.stdout.write(process.platform)")
export NIX_ENV := $(shell which sed | grep -qE "^/nix/store" && echo true|| echo false)
ifeq ($(PLATFORM),win32)
	BANG := !
	MAKE := make
	NULL := nul
	SHELL := cmd.exe
else
	BANG := \!
	NULL := /dev/null
	SHELL := $(shell bash --version >$(NULL) 2>&1 && echo bash|| echo sh)
endif
ifeq ($(NIX_ENV),true)
	export GREP ?= grep
	export SED ?= sed
else
ifeq ($(PLATFORM),darwin)
	export GREP ?= ggrep
	export SED ?= gsed
else
	export GREP ?= grep
	export SED ?= sed
endif
endif
ifeq ($(PLATFORM),linux)
	export NUMPROC ?= $(shell grep -c ^processor /proc/cpuinfo)
	export OPEN ?= xdg-open
else
	export OPEN ?= open
endif
ifeq ($(PLATFORM),darwin)
	export NUMPROC ?= $(shell sysctl hw.ncpu | awk '{print $$2}')
endif
export NUMPROC ?= 1
# MAKEFLAGS += "-j $(NUMPROC)"

.EXPORT_ALL_VARIABLES:

.PHONY: all
all: build

.PHONY: build
build:
	@docker-compose -f docker-build.yaml build $(ARGS)

.PHONY: pull
pull:
	@docker-compose -f docker-build.yaml pull $(ARGS)

.PHONY: push
push:
	@$(MAKE) -s +push
+push:
	@docker-compose -f docker-build.yaml push $(ARGS)

.PHONY: ssh
ssh:
	@$(MAKE) -s +ssh
+ssh:
	@docker ps | grep -E "$(NAME)$$" >/dev/null 2>&1 && \
		docker exec -it $(NAME) /bin/sh|| \
		docker run --rm -it --entrypoint /bin/sh $(IMAGE):latest

.PHONY: logs
logs:
	@docker-compose logs -f $(ARGS)

.PHONY: up
up:
	@$(MAKE) -s +up
+up:
	@docker-compose up $(ARGS)

.PHONY: stop
stop:
	@docker-compose stop $(ARGS)

.PHONY: clean
clean:
	-@docker-compose kill
	-@docker-compose down -v --remove-orphans
	-@docker-compose rm -v
