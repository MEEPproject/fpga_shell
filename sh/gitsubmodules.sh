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


#!bin/bash
ROOT_DIR=$(pwd)
ACC_DIR=$ROOT_DIR/accelerator
REPO_URL=$1
REPO_SHA=$2
#REPO_URL="https://gitlab.bsc.es/meep/rtl_designs/meep_dvino.git"

#whoami ? gilab-runner -> don't do the update

## Retrieve MEEP IPs --> Aurora, Ethernet ...
git submodule update --init
echo "[MEEP] INFO: Retrieving $IP_NAME as accelerator..."
git clone $REPO_URL accelerator
cd $ACC_DIR
git checkout $REPO_SHA 
cd $ROOT_DIR
echo "[MEEP] INFO: Done"
