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

OUTPUT_FILE=$1

stty -F /dev/ttyUSB2 115200 raw -echo
cat < /dev/ttyUSB2 > $OUTPUT_FILE &

echo "Sleep 5 minutes to let the UART output to be copied into the $OUTPUT_FILE file ..."

for i in 1 2 3 4 5
do
	sleep 60
	tail $OUTPUT_FILE
	echo "Wait 1 minute for the next output ($i/5)..."
done

echo "Kill cat process ..."

{ 
	sudo pkill cat 2> $OUTPUT_FILE.error 
} || { 
	echo "pkill cat command failed:"
	cat $OUTPUT_FILE.error || ls
}

echo "FPGA Test completed."

ls -l $OUTPUT_FILE

