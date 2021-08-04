#!/bin/bash

sh/define_shell.sh

if [ -d "binaries" ]; then
	echo "binaries folder already exists"
else
mkdir -p binaries
fi

cp -r accelerator/meep_shell/binaries/* binaries/

vivado -mode batch -nolog -nojournal -notrace -source ./tcl/init_ips.tcl
vivado -mode tcl   -nolog -nojournal -notrace -source ./tcl/gen_top.tcl
vivado -mode batch -nolog -nojournal -notrace -source ./tcl/gen_project.tcl
