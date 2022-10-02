#!/bin/bash

mkdir -p meep_shell; cd meep_shell

echo -e "EANAME=<thisEA>" >> accelerator_def.csv

echo -e "// This file is a module definition of the EA top file" >> accelerator_mod.sv
echo -e "#!/bin/bash \r\n# This is script initializes the EA (e.g, prepare submodules)" >> accelerator_init.sh

echo -e "#!/bin/bash \r\n# This script is used to build RTL files that are not present directly after cloning the repository (e.g, automatic generated files)" >> accelerator_build.sh

echo -e "#!/bin/bash \r\n# This script is used to build potential binaries (e.g, bootrom, OpenSBI, buildroot " >> accelerator_bin.sh


mkdir -p tcl
mkdir -p ip
mkdir -p xdc
mkdir -p src
mkdir -p bd
mkdir -p binaries

echo -e "# This TCL script adds the EA vivado configuration that is needed for Vivado to add the RTL source files and macro definitions" >> tcl/project_options.tcl

echo -e "Add here any constraint file that is needed for the EA" >> xdc/README.md
