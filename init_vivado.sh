#!/bin/bash

vivado -mode tcl   -nolog -nojournal -notrace -source ./tcl/gen_top.tcl
vivado -mode batch -nolog -nojournal -notrace -source ./tcl/gen_project.tcl
