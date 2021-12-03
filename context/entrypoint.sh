#!/bin/sh

# File: /context/entrypoint.sh
# Project: docker-openldap
# File Created: 15-08-2021 01:53:18
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 03-12-2021 14:58:16
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

if [ "$KERBEROS_REALM" = "" ]; then
    export KERBEROS_REALM="$LDAP_DOMAIN"
fi
if [ "$LDAP_BASE_DN" = "" ]; then
    export LDAP_BASE_DN=$(echo dc=$(echo $LDAP_DOMAIN | sed 's|\..*$||g'),dc=$(echo $LDAP_DOMAIN | sed 's|^.*\.||g'))
fi

__ldapready() {
    ldapsearch -c -Y EXTERNAL -H ldapi:/// -b "$LDAP_BASE_DN" -s base 2>&1 | \
        tee /tmp/ldapready.log
    cat /tmp/ldapready.log | grep -q "Can't contact LDAP server"
    if [ "$?" = "0" ]; then
        false
    fi
}

__ldapready_check() {
    while ! __ldapready; do
        echo LDAP not ready yet . . .
        sleep 10
    done
    touch /tmp/ldap_ready
    echo LDAP is ready!!!
}

__ldapadd() {
    if [ ! -f /tmp/ldap_ready ]; then
        false
    fi
    ldapadd -c -Y EXTERNAL -H ldapi:/// -f $1 2>&1 | \
        tee /tmp/ldapready.log
    cat /tmp/ldapready.log | grep -q "Can't contact LDAP server"
    if [ "$?" = "0" ]; then
        false
    fi
}

__load_ldif() {
    mkdir -p /container/ldif
    mkdir -p /etc/confd/conf.d
    mkdir -p /etc/confd/templates
    CWD=$(pwd)
    cd /container/service/slapd/assets/config/templates/ldif
    for f in $(find . -type f -name '*.ldif.tmpl' | sed 's|^\.\/||g'); do
        mkdir -p $(echo "/container/ldif/${f}" | sed 's|\/[^\/]*$||g')
        cp "/container/service/slapd/assets/config/templates/ldif/${f}" "/etc/confd/templates/${f}"
        cat <<EOF > "/etc/confd/conf.d/$(echo $f | sed 's|\/|_|g').toml"
[template]
src  = "${f}"
dest = "/container/ldif/$(echo $f | sed 's|\.tmpl$||g')"
EOF
    done
    for f in $(find . -type f -name '*.ldif' | sed 's|^\.\/||g'); do
        mkdir -p $(echo "/container/ldif/${f}" | sed 's|\/[^\/]*$||g')
        cp "/container/service/slapd/assets/config/templates/ldif/${f}" "/container/ldif/${f}"
    done
    cd $CWD
    confd -onetime -backend env
    for f in $(find /container/ldif -type f -name '*.ldif'); do
        echo 'ldapadd -c -Y EXTERNAL -H ldapi:/// -f' $f
        until __ldapadd $f
        do
            echo trying ldapadd again in 10 seconds . . .
            sleep 10
        done
    done
}

__auditlog() {
    while true; do
        if [ -f /tmp/ldap_ready ]; then
            runuser -l openldap -c "truncate -s 0 $LDAP_AUDITLOG_FILE"
        fi
        sleep 360
    done
}

__ldapready_check &

__load_ldif &

if [ "$LDAP_AUDITLOG" != "" ] && [ "$(echo $LDAP_AUDITLOG | awk '{print tolower($0)}')" != "false" ] && \
    [ "$LDAP_AUDITLOG_TRUNCATE" != "" ] && [ "$(echo $LDAP_AUDITLOG_TRUNCATE | awk '{print tolower($0)}')" != "false" ]; then
    __auditlog &
fi

exec /container/tool/run $@
