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


#!/bin/bash

EMPTY=""
EA_REPO="EMULATED_ACCELERATOR_REPO"
EA_SHA="EMULATED_ACCELERATOR_SHA"
DEF_FILE="ea_url.txt"
YAML_FILE=$1
TOKEN=$2

if [ "$YAML_FILE" = "" ]; then
	YAML_FILE=".gitlab-ci.yml"
	TOKEN="\\\$RTL_REPO_TOKEN"
fi

# Seach the YAML File token-based URL and convert it to a normal URL
EA_REPO_TMP=$(grep $DEF_FILE -e "$EA_REPO") 
# Take a normal URL and insert the token-based string
EA_REPO_YAML=$(grep $DEF_FILE -e "$EA_REPO" | sed "s/https:\/\//https:\/\/gitlab-ci-token:$TOKEN@/")


echo "$EA_REPO_TMP"
echo "$EA_REPO_YAML"

#Substitue the entire line where a match to $EA_REPO has been found thanks to .* after the matching 
#string. If .* is not present, only the matching string gets substitued.
sed -i "0,/$EA_REPO/{s|$EA_REPO.*|$EA_REPO_YAML|}" $YAML_FILE

#Do the same process (almost) for the SHA line
#1 obtain the right line
EA_SHA_TMP=$(grep $DEF_FILE -e "$EA_SHA")

echo "$EA_SHA_TMP"

#switch the lines

sed -i "0,/$EA_SHA/{s|$EA_SHA.*|$EA_SHA_TMP|}" $YAML_FILE



