# File: /Makefile
# Project: docker-openldap
# File Created: 24-06-2021 04:03:49
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 14-07-2021 21:29:44
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

NAME := openldap
REGISTRY := codejamninja
VERSION := 0.0.1
IMAGE := $(REGISTRY)/$(NAME)

include docker.mk

.PHONY: postgres
postgres:
	@docker-compose up $(ARGS) postgres

.PHONY: keycloak
keycloak:
	@docker-compose up $(ARGS) keycloak

.PHONY: redis
redis:
	@docker-compose up $(ARGS) redis

.PHONY: deps
deps:
	@docker-compose up $(ARGS) deps

.PHONY: ~%
~%:
	@$(MAKE) -s $(shell echo $@ | $(SED) 's/^~//g') ARGS="-d"

.PHONY: %
%: ;