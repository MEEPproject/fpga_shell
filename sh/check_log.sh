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

INPUT_FILE=$1
GOOD_STRING=$2

echo "Checking FPGA log file..."

if [ ! -f "$INPUT_FILE" ]; then
       printf "Log file doesn't exist!\n"	
       exit 1
fi

FILE_SIZE=$(ls -ltr $INPUT_FILE | nawk '{printf $5}')

echo "File size is $FILE_SIZE bytes"

if [ "$FILE_SIZE" -eq "0" ]; then
	echo "FPGA Log is empty, something went wrong, finishing..."
	exit 1
fi

ret=0


#If the good string is found, the variable is NOT empty and the next if is not taken
LoginPrompt="`grep $INPUT_FILE -e "$GOOD_STRING" || true`"
echo $LoginPrompt

if [ -z "$LoginPrompt" ]; then	
    echo "The log output is not as expected"
    ret=1
fi

if [ "$ret" -eq 1 ]; then
    echo "Log validation failed"
    exit 1
else
    echo "Log validation passed"
    #exit 0
fi	

