# File: /Makefile
# Project: docker-openldap
# File Created: 24-06-2021 04:03:49
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 11-07-2023 12:30:28
# Modified By: Clay Risser <email@clayrisser.com>
# -----
# BitSpur (c) Copyright 2021
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

include mkpm.mk
ifneq (,$(MKPM_READY))
include $(MKPM)/gnu

export DOCKER_COMPOSE := docker-compose
export CONTEXT := context
export NAME ?= docker-openldap
export REGISTRY ?= registry.gitlab.com/bitspur/rock8s
export VERSION ?= 2.4.57

include $(MKPM)/docker

endif
