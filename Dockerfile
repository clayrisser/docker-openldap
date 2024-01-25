# File: /Dockerfile
# Project: docker-openldap
# File Created: 15-08-2021 01:53:18
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 25-01-2024 04:20:43
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

WORKDIR /tmp

# setup openldap build environment
RUN echo > /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian buster-updates main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian buster main" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian buster-updates main" >> /etc/apt/sources.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    build-essential \
    curl \
    dpkg-dev \
    libgcrypt20-dev \
    libkrb5-dev \
    libssl-dev \
    make \
    unzip
RUN apt-get build-dep slapd -y

# get confd
RUN curl -LO https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 && \
    mv confd-0.16.0-linux-amd64 confd

RUN echo 3 > /dev/null # nonce
RUN mkdir -p debs

# prepare hello_world module
RUN curl -L -o hello_world.tar.gz \
    https://gitlab.com/bitspur/community/hello-world-openldap-overlay/-/archive/main/hello-world-openldap-overlay-main.tar.gz && \
    tar -xzvf hello_world.tar.gz && mv hello-world-openldap-overlay-main hello_world && \
    make -s -C hello_world prepare WORKDIR=..

# prepare mbkrb5pwd module
RUN curl -L -o mbkrb5pwd.zip https://codeload.github.com/opinsys/smbkrb5pwd/zip/refs/heads/master && \
    unzip mbkrb5pwd.zip && \
    mv smbkrb5pwd-master openldap/contrib/slapd-modules/smbkrb5pwd && \
    sed -i 's|^CONTRIB_MODULES = |CONTRIB_MODULES = smbkrb5pwd |g' openldap/debian/rules && \
    echo "usr/lib/ldap/smbkrb5pwd.so*" >> openldap/debian/slapd.install && \
    echo "usr/lib/ldap/smbkrb5pwd.la" >> openldap/debian/slapd.install

# prepare mbkrb5pwd_srv module
RUN curl -L -o mbkrb5pwd_srv.zip https://codeload.github.com/opinsys/smbkrb5pwd/zip/refs/heads/no_kadmin && \
    unzip mbkrb5pwd_srv.zip && \
    mv smbkrb5pwd-no_kadmin openldap/contrib/slapd-modules/smbkrb5pwd_srv && \
    sed -i 's|^CONTRIB_MODULES = |CONTRIB_MODULES = smbkrb5pwd_srv |g' openldap/debian/rules && \
    echo "usr/lib/ldap/smbkrb5pwd_srv.so*" >> openldap/debian/slapd.install && \
    echo "usr/lib/ldap/smbkrb5pwd_srv.la" >> openldap/debian/slapd.install

# compile openldap
RUN make -s -C hello_world build WORKDIR=..

RUN apt-get -y update && \
    (dpkg -i /tmp/debs/*.deb || true) && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -f -y && \
    dpkg -i /tmp/debs/*.deb

FROM osixia/openldap:1.5.0

COPY --from=builder /tmp/confd /usr/local/bin/confd
COPY --from=builder /tmp/debs /tmp/debs
COPY --from=builder /usr/lib/ldap /tmp/lib/ldap

ARG OPENLDAP_PACKAGE_VERSION=2.4.57

# RUN apt-get -y update && \
#     (dpkg -i /tmp/debs/*.deb || true) && \
#     LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -f -y && \
#     dpkg -i /tmp/debs/*.deb && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
#     chmod +x /usr/local/bin/confd

RUN apt-get clean && \
    cp -rn /tmp/lib/ldap/* /usr/lib/ldap && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chmod +x /usr/local/bin/confd && \
    mkdir -p /home/openldap /var/log/slapd/auditlog && \
    chown -R openldap:openldap /home/openldap /var/log/slapd/auditlog

ADD bootstrap /container/service/slapd/assets/config/bootstrap
ADD templates /container/service/slapd/assets/config/templates
ADD entrypoint.sh /usr/local/sbin/entrypoint

RUN chmod +x /usr/local/sbin/entrypoint

ENTRYPOINT [ "/bin/sh", "/usr/local/sbin/entrypoint" ]

ENV LDAP_AUDITLOG=FALSE \
    LDAP_AUDITLOG_FILE=/var/log/slapd/auditlog/auditlog.log \
    LDAP_AUDITLOG_TRUNCATE=TRUE \
    LDAP_HASH_PASSWORD=SHA512CRYPT \
    LDAP_SMBKRB5PWD=FALSE \
    LDAP_SYNCREPL=FALSE
