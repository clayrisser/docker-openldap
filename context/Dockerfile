# File: /context/Dockerfile
# Project: docker-openldap
# File Created: 15-08-2021 01:53:18
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 24-08-2021 12:57:18
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

FROM osixia/openldap:1.5.0

ADD ppolicy.ldif /container/service/slapd/assets
ADD bootstrap /container/service/slapd/assets/config/bootstrap
ADD entrypoint.sh /usr/local/sbin/entrypoint

RUN chmod +x /usr/local/sbin/entrypoint

ENTRYPOINT [ "/bin/sh", "/usr/local/sbin/entrypoint" ]

ENV LDAP_HASH_PASSWORD=true
