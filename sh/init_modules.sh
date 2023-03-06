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

#we need to write here the .gitsubmodules file, so this process receives that
#label as a parameter and the ci/cd can proceed. The accelerator is received.
#Then, call <accelerator_init.sh>, to trigger the needed processes.
ROOT_DIR=$(pwd)
ACC_DIR=$ROOT_DIR/accelerator
SH_DIR=$ROOT_DIR/sh

EA_GIT_URL=$1
EA_GIT_SHA=$2

if [ "$#" -ne 2 ]; then
    echo "[MEEP] Error: Illegal number of parameters, terminating"
	echo "[MEEP] INFO: Usage: generate.sh <accelerator_repo>"
	return -1
fi
#Removed debug execution
bash -x $SH_DIR/gitsubmodules.sh $EA_GIT_URL $EA_GIT_SHA
#Generic call to accelerator conf script. It should be meep_shell/accelerator_init.sh
cd $ACC_DIR

# Find the meep_shell directory based on a typical shell file name
# TODO: Probably checking for the whole set of meep shell files makes more sense
MEEP_DIR=$(find $ROOT_DIR -name accelerator_def.csv -printf '%h\n' | sort -u)
echo "[MEEP] INFO: The meepshell folder found at: $MEEP_DIR"
# Create a symlink in the accelerator root directory
# in case the user has not placed it there.
if [ "$MEEP_DIR" != $ACC_DIR/meep_shell ] ; then
 ln -sf $MEEP_DIR $ACC_DIR/meep_shell
 echo "[MEEP] INFO: SymLink to $MEEP_DIR created"
else
 echo "[MEEP] INFO: The EA is already placed in the EA root directory"
 echo "[MEEP] INFO: SymLink won't be created"
fi

bash -x $ACC_DIR/meep_shell/accelerator_init.sh $ACC_DIR
cd $ROOT_DIR
#Make a make inside DVINO
