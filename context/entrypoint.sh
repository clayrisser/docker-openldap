#!/bin/sh

# File: /context/entrypoint.sh
# Project: docker-openldap
# File Created: 15-08-2021 01:53:18
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 15-08-2021 03:59:51
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
    ldapadd -c -Y EXTERNAL -H ldapi:/// -f /container/service/slapd/assets/ppolicy.ldif 2>&1 | \
        tee /tmp/ldapadd.log
    cat /tmp/ldapadd.log | grep -q "Can't contact LDAP server"
    if [ "$?" = "0" ]; then
        false
    fi
}

__hash_password() {
    until __ldapadd
    do
        echo trying ldapadd again in 60 seconds . . .
        sleep 60
    done
}

if [ "$LDAP_HASH_PASSWORD" = "true" ]; then
    __hash_password &
fi

exec /container/tool/run --copy-service $@
