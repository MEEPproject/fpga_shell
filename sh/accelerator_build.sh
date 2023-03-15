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
# Updated by Fran. Check if original accelerator_build return a fail or succed exit status

BR='\033[1;31m'     #Bold Red 
NC='\033[0;0;0m'    #NO COLOR

cd accelerator

# execute accelerator_build using no debug mode
meep_shell/accelerator_build.sh $1 $2 $3 $4 $5 $6 $7 $8 

#check the exit status of accelerator_build.sh
if [ "$?" -eq 1 ]; then
    
    echo -e  ${BR}"accelerator_build.sh has failed during the execution: make project" ${NC}
    exit 1
else
    
    echo "accelerator_build.sh has succeded"
    exit 0
fi


cd ..
