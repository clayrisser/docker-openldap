#!/bin/sh

# File: /context/entrypoint.sh
# Project: docker-openldap
# File Created: 15-08-2021 01:53:18
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 01-09-2021 23:18:48
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

__ldapadd() {
    ldapadd -c -Y EXTERNAL -H ldapi:/// -f $1 2>&1 | \
        tee /tmp/ldapadd.log
    cat /tmp/ldapadd.log | grep -q "Can't contact LDAP server"
    if [ "$?" = "0" ]; then
        false
    fi
}

__load_ldif() {
    if [ "$LDAP_BASE_DN" = "" ]; then
        export LDAP_BASE_DN=$(echo dc=$(echo $LDAP_DOMAIN | sed 's|\..*$||g'),dc=$(echo $LDAP_DOMAIN | sed 's|^.*\.||g'))
    fi
    mkdir -p /etc/confd/conf.d
    mkdir -p /etc/confd/templates
    for f in $(ls /container/service/slapd/assets/config/bootstrap/ldif | grep -E "\.ldif\.tmpl$"); do
        mkdir -p $(echo "/container/ldif/$f" | sed 's|\/[^\/]*$||g')
        cp "/container/service/slapd/assets/config/bootstrap/ldif/${f}" "/etc/confd/templates/${f}"
        cat <<EOF > "/etc/confd/conf.d/${f}.toml"
[template]
src  = "${f}"
dest = "/container/ldif/$(echo $f | sed 's|\.tmpl$||g')"
EOF
    done
    for f in $(ls /container/service/slapd/assets/config/bootstrap/ldif | grep -E "\.ldif$"); do
        mkdir -p $(echo "/container/ldif/$f" | sed 's|\/[^\/]*$||g')
        cp /container/service/slapd/assets/config/bootstrap/ldif/$f /container/ldif/$f
    done
    if [ "$LDAP_HASH_PASSWORD" != "" ] && \
        [ "$(echo $LDAP_HASH_PASSWORD | awk '{ print toupper($0) }')" != "FALSE" ] && \
        [ "$(echo $LDAP_HASH_PASSWORD | awk '{ print toupper($0) }')" != "NONE" ]; then
        cp /container/service/slapd/assets/ppolicy.ldif.tmpl /etc/confd/templates/ppolicy.ldif.tmpl
        cat <<EOF > /etc/confd/conf.d/ppolicy.ldif.toml
[template]
src  = "ppolicy.ldif.tmpl"
dest = "/container/ldif/10-ppolicy.ldif"
EOF
    fi
    confd -onetime -backend env
    for f in $(find /container/ldif -type f -name '*.ldif'); do
        until __ldapadd $f
        do
            echo trying ldapadd again in 30 seconds . . .
            sleep 30
        done
    done
}

__load_ldif &

exec /container/tool/run $@
