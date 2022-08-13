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
#sh/define_shell.sh
LOG_FILE=shell_build.log
VIVADO_XLNX=$(which vivado)
export FPGA_SHELL_ROOT=`pwd`

if [ "$VIVADO_XLNX" = "" ]; then
	echo -e "\r\n"
	echo "[MEEP] INFO: Vivado Path not provided. Make sure you have it added to your PATH"
	VIVADO_XLNX="vivado"
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
CR='\U+2261'

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "This DIR: $SCRIPT_DIR"

echo -e "\r\n"
echo "[MEEP] ***************************************"
echo -e "[MEEP] *** $YELLOW MEEP SHELL GENERATION PROCESS$NC  ***"
echo "[MEEP] ***************************************"
echo "[MEEP] *                                     *"
echo "[MEEP] *   https://www.bsc.es/               *"
echo "[MEEP] *   https://meep-project.eu/          *"
echo "[MEEP] *                                     *"
echo -e "[MEEP] ***************************************\r\n"

EAURL=`grep -o ea_url.txt -e https.*$`
EANAME=$(grep -o ea_url.txt -e NAME.*$ | awk -F ':' '$2 {print $2}')

echo -e "[MEEP] Emulated accelerator:$EANAME\r\n\r\n\t$GREEN $EAURL $NC\r\n"


### Call the main program
$VIVADO_XLNX -mode batch -nolog -nojournal -notrace -source ./tcl/gen_meep.tcl | tee $LOG_FILE

CriticalWarnings=$(grep -riw $LOG_FILE -e Critical)

if [ -n "$CriticalWarnings" ]; then	
	echo -e "$YELLOW[MEEP] Critical warnings summary: $NC\r\n"
	echo "$CriticalWarnings"
fi
