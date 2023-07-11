#!/bin/sh

# File: /context/tmpl.sh
# Project: docker-openldap
# File Created: 11-07-2023 13:26:41
# Author: Clay Risser <email@clayrisser.com>
# -----
# Last Modified: 11-07-2023 14:14:16
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

EOF=EOF
exec cat <<EOF | sh
cat <<EOF
$(cat $1 | \
    sed 's|\\|\\\\|g' | \
    sed 's|`|\\`|g' | \
    sed 's|\$|\\\$|g' | \
    sed "s|${OPEN:-<%}|\`echo |g" | \
    sed "s|${CLOSE:-%>}| 2>/dev/null \`|g")
$EOF
EOF
