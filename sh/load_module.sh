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


 
MODULE=$1
MODULE=${MODULE,,}
ROOT_DIR=$(pwd)
EA_FILE=$ROOT_DIR/ea_url.txt
SUPP_DIR=$ROOT_DIR/support

EA_NAME=$(grep -r -m 1 $EA_FILE -e 'EMULATED_ACCELERATOR_NAME' | awk -F ':' '$2 {print $2}')
SUPP_LIST=$(find $SUPP_DIR/* -maxdepth 1 -type d -printf "%f\n")

 
if [ "$MODULE" == "" ]; then
       echo "[MEEP] INFO: Loading$EA_NAME module"	       	   
else
	if [ ! -d "$SUPP_DIR/$MODULE" ]; then
       echo -e "[MEEP] INFO: Module $MODULE directory doesn't exist!"	
	   echo -e "Supported modules:\r\n\r\n$SUPP_LIST"
       #exit 1
	else
		echo -e "\r\nLoading module $MODULE"
		cp $SUPP_DIR/$MODULE/ea_url.txt $EA_FILE
    fi	   
fi

