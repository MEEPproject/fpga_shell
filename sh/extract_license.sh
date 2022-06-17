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


OLD_STRING=$1
NEW_STRING=$2
INPUT_FILE=$3


#Substitue the entire line where a match to $FPGA_BOARD has been found thanks to .* after the matching
#string. If .* is not present, only the matching string gets substitued.

sed -i 's/$OLD_STRING/$NEW_STRING/g' $INPUT_FILE



