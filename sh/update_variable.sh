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


PRIVATE_TOKEN=$1
NEW_VALUE=$2

GITLAB_URL="https://gitlab.bsc.es/"
project="FPGA_implementations%2FAlveoU280%2Ftest_cicd"
group="meep"


response=$(curl --request POST "$GITLAB_URL/api/v4/projects/${group}%2F${project}/variables" \
 --form "key=LAST_SUCCESS" \
 --form "value=$NEW_VALUE" \
 --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" )
 
 echo "$response"
	 

#Update	 
# curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
     # "https://gitlab.example.com/api/v4/groups/1/variables/NEW_VARIABLE" --form "value=updated value"	 

# #Remove	 
# curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     # "https://gitlab.example.com/api/v4/groups/1/variables/VARIABLE_1"