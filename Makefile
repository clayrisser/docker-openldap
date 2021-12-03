# File: /Makefile
# Project: docker-openldap
# File Created: 24-06-2021 04:03:49
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 03-12-2021 05:12:43
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

include mkpm.mk
-include $(MKPM)/gnu
ifneq (,$(MKPM_READY))

export CONTEXT := context
export NAME ?= docker-openldap
export REGISTRY ?= registry.gitlab.com/silicon-hills/community
export VERSION ?= 0.0.1

-include $(MKPM)/docker

.PHONY: ~%
~%:
	@$(MAKE) -s $(subst ~,,$@) ARGS="-d"

endif
