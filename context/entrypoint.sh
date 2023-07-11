#!/bin/sh

# File: /context/entrypoint.sh
# Project: docker-openldap
# File Created: 11-07-2023 13:29:55
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 11-07-2023 13:59:01
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

if [ -d /tmp/ldifs ]; then
    cp -r /tmp/ldifs/* /ldifs
fi
if [ -d /tmp/schemas ]; then
    cp -r /tmp/schemas/* /schemas
fi

for l in $(ls ldifs); do
    if echo "$l" | sed -n '/\.tmpl$/p' >/dev/null; then
        tmpl ldifs/$l > ldifs/$(echo "$l" | sed 's|\.tmpl$||')
        rm -rf ldifs/$l
    fi
done
for s in $(ls schemas); do
    if echo "$s" | sed -n '/\.tmpl$/p' >/dev/null; then
        tmpl schemas/$s > schemas/$(echo "$s" | sed 's|\.tmpl$||')
        rm -rf schemas/$s
    fi
done

exec /opt/bitnami/scripts/openldap/_entrypoint.sh "$@"
