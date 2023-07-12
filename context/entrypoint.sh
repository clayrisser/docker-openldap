#!/bin/sh

# File: /context/entrypoint.sh
# Project: docker-openldap
# File Created: 11-07-2023 13:29:55
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 12-07-2023 12:33:55
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

apply_config() {
    until ldapwhoami -Y EXTERNAL -H ldapi:/// 2>/dev/null; do
        sleep 5
    done
    for f in $(ls $LDAP_CUSTOM_CONFIG_DIR); do
        echo ldapmodify -Y EXTERNAL -H ldapi:/// -f $LDAP_CUSTOM_CONFIG_DIR/$f
        ldapmodify -Y EXTERNAL -H ldapi:/// -f $LDAP_CUSTOM_CONFIG_DIR/$f
    done
}

if [ -d /tmp/ldifs ]; then
    cp -r /ldifs/* $LDAP_CUSTOM_LDIF_DIR
fi
if [ -d /tmp/schemas ]; then
    cp -r /schemas/* $LDAP_CUSTOM_SCHEMA_DIR
fi
if [ -d /tmp/config ]; then
    cp -r /config/* $LDAP_CUSTOM_CONFIG_DIR
fi

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
for c in $(ls $LDAP_CUSTOM_CONFIG_DIR); do
    if echo "$c" | grep -q '\.tmpl$'; then
        tmpl $LDAP_CUSTOM_CONFIG_DIR/$c > $LDAP_CUSTOM_CONFIG_DIR/$(echo "$c" | sed 's|\.tmpl$||')
        rm -rf $LDAP_CUSTOM_CONFIG_DIR/$c
    fi
done

apply_config &

exec /opt/bitnami/scripts/openldap/_entrypoint.sh "$@"
