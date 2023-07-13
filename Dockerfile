# File: /Dockerfile
# Project: docker-openldap
# File Created: 15-08-2021 01:53:18
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 13-07-2023 05:45:20
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

FROM bitnami/openldap:2.5.15 as builder

WORKDIR /tmp

USER 0

# setup openldap build environment
RUN echo "deb-src http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org bullseye-security main" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian bullseye-updates main" >> /etc/apt/sources.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    build-essential \
    curl \
    dpkg-dev \
    libgcrypt20-dev \
    libkrb5-dev \
    libssl-dev \
    make \
    schema2ldif \
    unzip
RUN apt-get build-dep slapd -y
RUN mkdir -p debs && \
    apt-get source slapd && \
    mv $(ls | grep -E "^openldap[^_].*") openldap

# prepare hello_world module
RUN curl -L -o hello_world.tar.gz \
    https://gitlab.com/bitspur/rock8s/hello-world-openldap-overlay/-/archive/main/hello-world-openldap-overlay-main.tar.gz && \
    tar -xzvf hello_world.tar.gz && \
    rm -rf openldap/contrib/slapd-modules/hello_world && \
    mv hello-world-openldap-overlay-main/src openldap/contrib/slapd-modules/hello_world && \
    sed -i 's|^CONTRIB_MODULES = |CONTRIB_MODULES = hello_world |g' openldap/debian/rules && \
    echo "usr/lib/ldap/hello_world.so*" >> openldap/debian/slapd.install && \
    echo "usr/lib/ldap/hello_world.la" >> openldap/debian/slapd.install

# prepare mbkrb5pwd module
RUN curl -L -o mbkrb5pwd.zip https://codeload.github.com/opinsys/smbkrb5pwd/zip/refs/heads/master && \
    unzip mbkrb5pwd.zip && \
    rm -rf openldap/contrib/slapd-modules/smbkrb5pwd && \
    mv smbkrb5pwd-master openldap/contrib/slapd-modules/smbkrb5pwd && \
    sed -i 's|^CONTRIB_MODULES = |CONTRIB_MODULES = smbkrb5pwd |g' openldap/debian/rules && \
    echo "usr/lib/ldap/smbkrb5pwd.so*" >> openldap/debian/slapd.install && \
    echo "usr/lib/ldap/smbkrb5pwd.la" >> openldap/debian/slapd.install

# prepare mbkrb5pwd_srv module
RUN curl -L -o mbkrb5pwd_srv.zip https://codeload.github.com/opinsys/smbkrb5pwd/zip/refs/heads/no_kadmin && \
    unzip mbkrb5pwd_srv.zip && \
    rm -rf openldap/contrib/slapd-modules/smbkrb5pwd_srv && \
    mv smbkrb5pwd-no_kadmin openldap/contrib/slapd-modules/smbkrb5pwd_srv && \
    sed -i 's|^CONTRIB_MODULES = |CONTRIB_MODULES = smbkrb5pwd_srv |g' openldap/debian/rules && \
    echo "usr/lib/ldap/smbkrb5pwd_srv.so*" >> openldap/debian/slapd.install && \
    echo "usr/lib/ldap/smbkrb5pwd_srv.la" >> openldap/debian/slapd.install

# compile openldap
RUN echo --enable-monitor >> openldap/debian/configure.options && \
    echo --enable-mdb >> openldap/debian/configure.options && \
    cd openldap && \
    CONFIG="--enable-monitor" \
    DEB_BUILD_OPTIONS='nocheck' dpkg-buildpackage -b -uc -us -j$(nproc) && \
    mv ../*.deb /tmp/debs
RUN (dpkg -i /tmp/debs/*.deb || true) && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -f -y && \
    dpkg -i /tmp/debs/*.deb

# convert schemas to ldif
COPY schemas /tmp/schemas
RUN mkdir -p ldif-schemas && for s in $(ls /tmp/schemas); do \
    if echo "$s" | grep -q '\.schema$'; then \
    echo converting "$s" to "$(basename schemas/$s .schema).ldif" && \
    schema2ldif "schemas/$s" > ldif-schemas/$(basename schemas/$s .schema).ldif; \
    elif ( (echo "$s" | grep -q '\.ldif$') || (echo "$s" | grep -q '\.tmpl$') ); then \
    echo copying "$s" && \
    cp "schemas/$s" ldif-schemas/$s; \
    fi \
    done

FROM bitnami/openldap:2.5.15

USER 0

COPY --from=builder /tmp/debs /tmp/debs
COPY --from=builder /tmp/ldif-schemas /opt/bitnami/openldap/schemas
COPY tmpl.sh /usr/local/bin/tmpl

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    libkadm5clnt-mit12 \
    libkadm5srv-mit12 \
    libkadm5srv8-heimdal \
    libkrb5-26-heimdal \
    slapd-contrib && \
    (dpkg -i /tmp/debs/*.deb || true) && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -f -y && \
    dpkg -i /tmp/debs/*.deb && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chmod +x /usr/local/bin/tmpl && \
    mv /opt/bitnami/scripts/openldap/entrypoint.sh /opt/bitnami/scripts/openldap/_entrypoint.sh

COPY ldifs /opt/bitnami/openldap/ldifs
COPY migrations /opt/bitnami/openldap/migrations
COPY entrypoint.sh /opt/bitnami/scripts/openldap/entrypoint.sh

RUN chmod +x /opt/bitnami/scripts/openldap/entrypoint.sh && \
    export LDAP_BASE_DIR="/opt/bitnami/openldap" && \
    export PATH="/usr/sbin:/usr/bin:$PATH" && \
    for f in $(ls ${LDAP_BASE_DIR}/bin); do \
    if [ "$(which $f)" = "/usr/bin/$f" ]; then \
    rm ${LDAP_BASE_DIR}/bin/$f && \
    ln -s $(which $f) ${LDAP_BASE_DIR}/bin/$f; \
    fi; \
    done &&  \
    for f in $(ls ${LDAP_BASE_DIR}/sbin); do \
    if [ "$(which $f)" = "/usr/sbin/$f" ]; then \
    rm ${LDAP_BASE_DIR}/sbin/$f && \
    ln -s $(which $f) ${LDAP_BASE_DIR}/sbin/$f; \
    fi; \
    done && \
    for s in $(ls /etc/ldap/schema); do \
    cp /etc/ldap/schema/$s ${LDAP_BASE_DIR}/etc/schema/$s; \
    done && \
    rm -rf /etc/ldap && \
    mv ${LDAP_BASE_DIR}/etc /etc/ldap && \
    ln -s /etc/ldap ${LDAP_BASE_DIR}/etc && \
    rm -rf /usr/share/slapd && \
    mv ${LDAP_BASE_DIR}/share /usr/share/slapd && \
    ln -s /usr/share/slapd ${LDAP_BASE_DIR}/share && \
    rm -rf ${LDAP_BASE_DIR}/lib && \
    ln -s /usr/lib/ldap ${LDAP_BASE_DIR}/lib && \
    rm -rf ${LDAP_BASE_DIR}/libexec && \
    ln -s /usr/lib/ldap ${LDAP_BASE_DIR}/libexec && \
    rm -rf ${LDAP_BASE_DIR}/include && \
    ln -s /usr/include ${LDAP_BASE_DIR}/include && \
    mkdir -p /ldifs /schemas /migrations && \
    chown -R 1001:1001 \
    /migrations \
    /etc/ldap \
    /ldifs \
    /opt/bitnami/openldap/migrations \
    /opt/bitnami/openldap/ldifs \
    /opt/bitnami/openldap/schemas \
    /schemas \
    /usr/share/slapd \
    /var/lib/ldap \
    /var/run/slapd

USER 1001
LABEL org.opencontainers.image.version="2.4.57"
ENV APP_VERSION="2.4.57" \
    BITNAMI_DEBUG=true \
    LDAP_CUSTOM_MIGRATIONS_DIR=/opt/bitnami/openldap/migrations \
    LDAP_CUSTOM_LDIF_DIR=/opt/bitnami/openldap/ldifs \
    LDAP_CUSTOM_SCHEMA_DIR=/opt/bitnami/openldap/schemas \
    LDAP_HASH_PASSWORD=SHA256CRYPT \
    LDAP_LOGLEVEL=256 \
    LDAP_ROOT=dc=example,dc=org \
    LDAP_EXTRA_SCHEMAS=cosine,inetorgperson,nis,ppolicy
