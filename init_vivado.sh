#!/bin/bash
#sh/define_shell.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
CR='\U+2261'

echo -e "\r\n"
echo "[MEEP] ***************************************"
echo -e "[MEEP] *** $YELLOW MEEP SHELL GENERATION PROCESS$NC  ***"
echo "[MEEP] ***************************************"
echo "[MEEP] *                                     *"
echo "[MEEP] *   https://www.bsc.es/               *"
echo "[MEEP] *   https://meep-project.eu/          *"
echo "[MEEP] *                                     *"
echo -e "[MEEP] ***************************************\r\n"

EA=`grep -o ea_url.txt -e https.*$`

echo -e "[MEEP] Emulated accelerator: \r\n\r\n\t$GREEN $EA $NC\r\n"

if [ -d "binaries" ]; then
	echo "[MEEP] binaries folder already exists"
else
	echo "[MEEP] Creating binaries folder ..."
mkdir -p binaries
fi

cp -r accelerator/meep_shell/binaries/* binaries/

echo "[MEEP] INFO: Defining the shell environment file"
vivado -mode batch -nolog -nojournal -notrace -source ./tcl/define_shell.tcl
echo "[MEEP] INFO: Generating the shell IPs ..."
vivado -mode batch -nolog -nojournal -notrace -source ./tcl/init_ips.tcl
echo "[MEEP] INFO: Generating the RTL top file ..."
vivado -mode tcl   -nolog -nojournal -notrace -source ./tcl/gen_top.tcl
echo "[MEEP] INFO: Creating the project ..."
vivado -mode batch -nolog -nojournal -notrace -source ./tcl/gen_project.tcl
