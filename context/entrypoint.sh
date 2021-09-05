#!/bin/sh

# File: /context/entrypoint.sh
# Project: docker-openldap
# File Created: 15-08-2021 01:53:18
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 05-09-2021 03:33:28
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
    mkdir -p /container/ldif
    mkdir -p /etc/confd/conf.d
    mkdir -p /etc/confd/templates
    CWD=$(pwd)
    cd /container/service/slapd/assets/config/bootstrap/ldif
    for f in $(find . -type f -name '*.ldif.tmpl' | sed 's|^\.\/||g'); do
        mkdir -p $(echo "/container/ldif/${f}" | sed 's|\/[^\/]*$||g')
        cp "/container/service/slapd/assets/config/bootstrap/ldif/${f}" "/etc/confd/templates/${f}"
        cat <<EOF > "/etc/confd/conf.d/$(echo $f | sed 's|\/|_|g').toml"
[template]
src  = "${f}"
dest = "/container/ldif/$(echo $f | sed 's|\.tmpl$||g')"
EOF
    done
    for f in $(find . -type f -name '*.ldif' | sed 's|^\.\/||g'); do
        mkdir -p $(echo "/container/ldif/${f}" | sed 's|\/[^\/]*$||g')
        cp "/container/service/slapd/assets/config/bootstrap/ldif/${f}" "/container/ldif/${f}"
    done
    cd $CWD
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
