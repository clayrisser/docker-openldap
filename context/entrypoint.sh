#!/bin/sh

# File: /context/entrypoint.sh
# Project: docker-openldap
# File Created: 11-07-2023 13:29:55
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 14-07-2023 08:27:41
# Modified By: Clay Risser <email@clayrisser.com>
# -----
# BitSpur (c) Copyright 2021 - 2023
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

apply_migrations() {
    until ldapwhoami -Y EXTERNAL -H ldapi:/// 2>/dev/null; do
        sleep 5
    done
    for m in $(ls $LDAP_CUSTOM_MIGRATIONS_DIR); do
        echo ldapmodify -Y EXTERNAL -H ldapi:/// -f $LDAP_CUSTOM_MIGRATIONS_DIR/$m
        ldapmodify -Y EXTERNAL -H ldapi:/// -f $LDAP_CUSTOM_MIGRATIONS_DIR/$m
    done
}

if [ "$LDAP_SCHEMAS" != "" ]; then
    export LDAP_EXTRA_SCHEMAS="$LDAP_EXTRA_SCHEMAS,$LDAP_SCHEMAS"
fi

if [ "$(ls /ldifs 2>/dev/null)" != "" ] || [ "$LDAP_SKIP_DEFAULT_TREE" = "yes" ]; then
    for l in $(ls /ldifs 2>/dev/null); do
        cat /ldifs/$l > $LDAP_CUSTOM_LDIF_DIR/$l
    done
    export LDAP_SKIP_DEFAULT_TREE="yes"
else
    rm -rf $LDAP_CUSTOM_LDIF_DIR
    mkdir -p $LDAP_CUSTOM_LDIF_DIR
fi
for s in $(ls /schemas 2>/dev/null); do
    cat /schemas/$s > $LDAP_CUSTOM_SCHEMA_DIR/$s
done
for m in $(ls /migrations 2>/dev/null); do
    cat /migrations/$m > $LDAP_CUSTOM_MIGRATIONS_DIR/$m
done

for l in $(ls $LDAP_CUSTOM_LDIF_DIR); do
    if echo "$l" | grep -q '\.tmpl$'; then
        tmpl $LDAP_CUSTOM_LDIF_DIR/$l > $LDAP_CUSTOM_LDIF_DIR/$(echo "$l" | sed 's|\.tmpl$||')
        rm -rf $LDAP_CUSTOM_LDIF_DIR/$l
    fi
done
for s in $(ls $LDAP_CUSTOM_SCHEMA_DIR); do
    if echo "$s" | grep -q '\.tmpl$'; then
        tmpl $LDAP_CUSTOM_SCHEMA_DIR/$s > $LDAP_CUSTOM_SCHEMA_DIR/$(echo "$s" | sed 's|\.tmpl$||')
        rm -rf $LDAP_CUSTOM_SCHEMA_DIR/$s
    fi
done
for m in $(ls $LDAP_CUSTOM_MIGRATIONS_DIR); do
    if echo "$m" | grep -q '\.tmpl$'; then
        tmpl $LDAP_CUSTOM_MIGRATIONS_DIR/$m > $LDAP_CUSTOM_MIGRATIONS_DIR/$(echo "$m" | sed 's|\.tmpl$||')
        rm -rf $LDAP_CUSTOM_MIGRATIONS_DIR/$m
    fi
done

apply_migrations &

exec /opt/bitnami/scripts/openldap/_entrypoint.sh "$@"
