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

GITLAB_URL="https://gitlab.bsc.es/"
GITLAB_TOKEN="vZbY2sBxUhDnCYG6gxRH"
group="meep"
project="FPGA_implementations%2FAlveoU280%2Frepo_generation_script"
branch="origin%2Fdevelop%2Fhbm"
job="219155"
THIS_REPO="FPGA_implementations%2FAlveoU280%2Frepo_generation_script"
LAST_BINARIES_JOB="219155"


curl -L --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/api/v4/projects/${group}%2F${project}/jobs/$job/artifacts" --output watcher
#curl -L --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.bsc.es/api/v4/projects/${project}/jobs/$LAST_BINARIES_JOB/artifacts" --output binaries.zip

