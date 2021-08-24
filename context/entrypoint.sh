#!/bin/sh

# File: /context/entrypoint.sh
# Project: docker-openldap
# File Created: 15-08-2021 01:53:18
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 24-08-2021 12:48:25
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
    cp -r /container/service/slapd/assets/config/bootstrap/ldif /container/ldif
    mkdir -p /container/ldif
    if [ "$LDAP_HASH_PASSWORD" = "true" ]; then
        cp /container/service/slapd/assets/ppolicy.ldif /container/ldif/ppolicy.ldif
    fi
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
