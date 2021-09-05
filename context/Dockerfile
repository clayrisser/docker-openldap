# File: /context/Dockerfile
# Project: docker-openldap
# File Created: 15-08-2021 01:53:18
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 04-09-2021 20:56:36
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

FROM osixia/openldap:1.5.0 as builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

RUN echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian buster-updates main" >> /etc/apt/sources.list && \
    echo "deb-src http://ftp.debian.org/debian buster-backports main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y \
    apt-utils \
    build-essential \
    curl \
    dpkg-dev \
    make
RUN apt-get build-dep slapd -y

RUN echo 8 > /dev/null # nonce
RUN mkdir -p debs
RUN curl -L -o hello_world.tar.gz \
    https://gitlab.com/bitspur/community/hello-world-openldap-overlay/-/archive/main/hello-world-openldap-overlay-main.tar.gz && \
    tar -xzvf hello_world.tar.gz && \
    mv hello-world-openldap-overlay-main hello_world
RUN cd hello_world && \
    make -s install && \
    mv debs/* ../debs

RUN curl -LO https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 && \
    mv confd-0.16.0-linux-amd64 confd

FROM osixia/openldap:1.5.0

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /tmp/confd /usr/local/bin/confd
COPY --from=builder /tmp/debs /tmp/debs
RUN apt-get update && \
    (dpkg -i /tmp/debs/*.deb || true) && \
    apt-get install -f -y && \
    dpkg -i /tmp/debs/*.deb && \
    apt-get clean && \
    rm -rf /tmp/debs /var/lib/apt/lists/* && \
    chmod +x /usr/local/bin/confd

ADD ppolicy.ldif.tmpl /container/service/slapd/assets
ADD bootstrap /container/service/slapd/assets/config/bootstrap
ADD entrypoint.sh /usr/local/sbin/entrypoint

RUN chmod +x /usr/local/sbin/entrypoint

ENTRYPOINT [ "/bin/sh", "/usr/local/sbin/entrypoint" ]

ENV LDAP_HASH_PASSWORD=SHA512CRYPT
