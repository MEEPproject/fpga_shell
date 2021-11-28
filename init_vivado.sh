#!/bin/bash
#sh/define_shell.sh
LOG_FILE=shell_build.log

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

EAURL=`grep -o ea_url.txt -e https.*$`
EANAME=`grep -o ea_url.txt -e EANAME.*$`

echo -e "[MEEP] Emulated accelerator: \r\n\r\n\t$GREEN $EAURL $NC\r\n"

if [ -d "binaries" ]; then
	echo "[MEEP] binaries folder already exists"
else
	echo "[MEEP] Creating binaries folder ..."
mkdir -p binaries
fi

cp -r accelerator/meep_shell/binaries/* binaries/

### Call the main program
vivado -mode batch -nolog -nojournal -notrace -source ./tcl/gen_meep.tcl | tee $LOG_FILE

CriticalWarnings=$(grep -riw $LOG_FILE -e Critical)

if [ -n "$CriticalWarnings" ]; then	
	echo -e "$YELLOW[MEEP] Critical warnings summary: $NC\r\n"
	echo "$CriticalWarnings"
fi
