#!/bin/bash
# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Solderpad Hardware License v 2.1 (the "License");
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
# 
#     http://www.solderpad.org/licenses/SHL-2.1
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Daniel J.Mazure, BSC-CNS
# Date: 22.02.2022
# Description:


BITSTREAM_PATH=$1
REPORT_FILE=$2

# Generate the sha of a bitstream file:
echo -n bitstream | sha256sum


#!/bin/bash

# Check if path is provided as parameter
if [ $# -ne 1 ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

# Check if path exists
if [ ! -d "$BITSTREAM_PATH" ]; then
  echo "Directory does not exist: $BITSTREAM_PATH"
  exit 1
fi

# Find all .bit files in the directory and calculate their SHA-256 hash
find "$BITSTREAM_PATH" -name '*.bit' -type f -print0 | while read -d $'\0' bitfile; do
  sha=sha256sum "$bitfile"
  mydate=$(date +%m.%d.%Y)
  python connector.py($sha,$bitfile,$mydate,$REPORT_FILE)
done

