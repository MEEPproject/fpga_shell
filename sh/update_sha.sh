#!/bin/bash
# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

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

# Author: Daniel J.Mazure, BSC-CNS
# Date: 22.02.2022
# Description: 


#!/bin/bash

ROOT_DIR=$(pwd)
EA_SHA="EMULATED_ACCELERATOR_SHA"
DEF_FILE=$1
ACC_DIR=$ROOT_DIR/accelerator

cd $ACC_DIR
EA_SHA_BRANCH=$(git branch --show-current)
EA_SHA_TMP=$(git rev-parse $EA_SHA_BRANCH)
cd $ROOT_DIR

echo "$EA_SHA: $EA_SHA_TMP"
NEW_SHA="$EA_SHA: $EA_SHA_TMP"

#switch the lines

sed -i "0,/$EA_SHA/{s|$EA_SHA.*|$NEW_SHA|}" $DEF_FILE



