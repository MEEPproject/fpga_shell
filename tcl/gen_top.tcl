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


set g_root_dir [pwd]

set g_acc_dir $g_root_dir/accelerator

file mkdir $g_root_dir/tmp
file mkdir $g_root_dir/src

source $g_root_dir/tcl/procedures.tcl
source $g_root_dir/tcl/shell_env.tcl

set g_head_file   $g_root_dir/misc/header.sv
set g_top_file    $g_root_dir/src/system_top.sv
set g_htmp_file   $g_root_dir/tmp/header_tmp.sv 
set g_mod_file    $g_root_dir/tmp/mod_tmp.sv
set g_inst_file   $g_root_dir/tmp/inst_tmp.sv
set g_tmp_file	  $g_root_dir/tmp/top_tmp.sv
set g_wire_file	  $g_root_dir/tmp/wire_tmp.sv
set g_shell_file  $g_root_dir/tmp/shell_tmp.sv
set g_eamap_file  $g_root_dir/tmp/ea_top_tmp.sv
set g_acc_file	  $g_acc_dir/meep_shell/accelerator_mod.sv


# if HBM is set to no, HBMCATTRIP needs to be forced to '0'.
# There is a better option, set HBMCATTRIP as pulldown in the constraints.
# Both are valid and can live together.


##################################################################
## Body
##################################################################

set fd_mod    [open $g_mod_file    "w"]
set fd_system [open $g_system_file "r"]


#puts $fd_mod    "module system_top"
#puts $fd_mod    "   ("

# Add the system level signals to the top level port (Clk, RST..)
fcopy $fd_system $fd_mod
close $fd_mod
close $fd_system

# 18/11/2021
# add_interface creates the TOP level I/O ports using 
# an existing template in the "interfaces" folder.
# It receives a filtered list of present physical interfaces.

foreach ifname $PortList {		
	 
	add_interface $ifname $g_mod_file 
}

# Close the top level module
# hbm_cattrip is used to close it as it always exists
set   fd_mod  [open $g_mod_file    "a"]
puts  $fd_mod "    output        hbm_cattrip "
close $fd_mod

## Here, the module definition file has been created and closed.

# Read the top module to extract the ports and create the corresponding
# signals to make the connections between the top ports and the Shell (BD)
# Connections between the shell and the EA need are yet to be created.
# TOP LEVEL PORTS <---> Shell instance

set fd_mod  [open $g_mod_file   "r"]
set fd_inst [open $g_inst_file  "w"]

add_instance $fd_mod $fd_inst

close $fd_mod
close $fd_inst

## Here, the shell instance is partially filled with connections 
## to the top level I/O ports.

##################################################################

# Parse the EA top module:
# The EA will be entirely connected to the MEEP Shell.
# EA ports <---> EA wires

set fd_mod   [open $g_acc_file   "r"]
set fd_inst  [open $g_eamap_file "w"]
set fd_wire  [open $g_wire_file  "w"]
set fd_shell [open $g_shell_file "w"]

parse_module $fd_mod $fd_inst $fd_wire $fd_shell

close $fd_mod
close $fd_inst
close $fd_wire
close $fd_shell


## Here, the EA instance has been created.

set   fd_top     [open $g_top_file   "w"]
set   fd_mod     [open $g_mod_file   "a"]
set   fd_inst    [open $g_inst_file  "r"]
set   fd_wire    [open $g_wire_file  "r"]
set   fd_shell   [open $g_shell_file "r"]


##################################################################
## Next, all the temp files are put together and neceesary sintax is added.
##################################################################

puts  $fd_mod    "   ); \r\n "
fcopy $fd_wire   $fd_mod
puts  $fd_mod    "\r\n meep_shell meep_shell_inst"
puts  $fd_mod    "   \("

# Put together the Shell-top connections and the EA-shell connections
fcopy $fd_inst    $fd_mod
#fcopy $fd_map   $fd_mod
fcopy $fd_shell   $fd_mod
puts  $fd_mod    "    .hbm_cattrip             \(hbm_cattrip\)"
puts  $fd_mod 	 "\);\r\n"
close $fd_wire
close $fd_shell
#close $fd_map
close $fd_inst
close $fd_mod

set   fd_mod      [open $g_mod_file    "r"]
# Create the top module boundaries
puts  $fd_top "module system_top"
puts  $fd_top "   \("
fcopy $fd_mod     $fd_top
close $fd_mod
# close the top file now.
close $fd_top


set   fd_top      [open $g_top_file    "a"]
set   fd_acc      [open $g_eamap_file  "r"]
fcopy $fd_acc $fd_top
puts  $fd_top    "\r\nendmodule"
close $fd_acc
close $fd_top

# Add the header to the top file
# To do so, concatenate the top to the head
# and rename

set fd_head       [open $g_head_file  "r"]
set fd_htmp       [open $g_htmp_file  "w"]
set fd_top        [open $g_top_file   "r"]
fcopy $fd_head $fd_htmp
fcopy $fd_top $fd_htmp
close $fd_head
close $fd_htmp
close $fd_top

file copy -force $g_htmp_file $g_top_file

putcolors "MEEP SHELL RTL top created" $GREEN

file delete -force $g_root_dir/tmp

