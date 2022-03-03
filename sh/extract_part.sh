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

ENV_FILE="tcl/environment.tcl"
FPGA_PART="g_fpga_part"
FPGA_BOARD="g_board_part"

FPGA_BOARD_NAME=$1
FPGA_PART_NAME=$2

FPGA_BOARD_COMMAND="$FPGA_BOARD $FPGA_BOARD_NAME"


#Substitue the entire line where a match to $FPGA_BOARD has been found thanks to .* after the matching
#string. If .* is not present, only the matching string gets substitued.

sed -i "0,/$FPGA_BOARD/{s|$FPGA_BOARD.*|$FPGA_BOARD_COMMAND|}" $ENV_FILE

if [ -n "$FPGA_PART_NAME" ]; then
  FPGA_PART_COMMAND="$FPGA_PART $FPGA_PART_NAME"
  #Do the same process for the FPGA PART if the parameters has been passed
  sed -i "0,/$FPGA_PART/{s|$FPGA_PART.*|$FPGA_PART_COMMAND|}" $ENV_FILE

fi

