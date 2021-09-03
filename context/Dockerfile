# File: /context/Dockerfile
# Project: docker-openldap
# File Created: 15-08-2021 01:53:18
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 03-09-2021 05:13:16
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

FROM debian:11.0-slim as builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    groff \
    groff-base \
    libdb-dev \
    libtool-bin \
    make

RUN curl -LO https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 && \
    mv confd-0.16.0-linux-amd64 confd

RUN git clone https://gitlab.com/bitspur/community/hello-world-openldap-overlay.git && \
    cd hello-world-openldap-overlay && \
    make install

FROM osixia/openldap:1.5.0

COPY --from=builder /tmp/confd /usr/local/bin/confd
COPY --from=builder /usr/lib/ldap /tmp/ldap/lib

RUN cp -r /tmp/ldap/lib/* /usr/lib/ldap && \
    rm -rf /tmp/ldap && \
    chmod +x /usr/local/bin/confd

ADD ppolicy.ldif.tmpl /container/service/slapd/assets
ADD bootstrap /container/service/slapd/assets/config/bootstrap
ADD entrypoint.sh /usr/local/sbin/entrypoint

RUN chmod +x /usr/local/sbin/entrypoint

ENTRYPOINT [ "/bin/sh", "/usr/local/sbin/entrypoint" ]

ENV LDAP_HASH_PASSWORD=SHA512CRYPT
