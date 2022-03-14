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


namespace eval _tcl {
proc get_script_folder {} {
    set script_path [file normalize [info script]]
    set script_folder [file dirname $script_path]
    return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

source $script_folder/procedures.tcl
putmeeps "The environment tcl will be sourced from ${script_folder}"
source $script_folder/environment.tcl
source $script_folder/shell_env.tcl

################################################################
# START
################################################################
set root_dir [ pwd ]

set g_project_name $g_project_name
set projec_dir $root_dir/project
set shell_dir $root_dir/meep_shell_bd
set bdName meep_shell_bd

file delete -force $projec_dir
file delete -force $shell_dir

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
    create_project $g_project_name $projec_dir -force -part $g_fpga_part
}

#MEEP Phase 2 part

putcolors "**** MEEP Board: $g_board_part ****" $GREEN

# CHANGE DESIGN NAME HERE
variable design_name
set design_name $g_project_name

# This needs to be defined before creating the block design 
set ip_dir_list [get_property ip_repo_paths [current_project]]
lappend ip_dir_list $root_dir/ip
set_property  ip_repo_paths  $ip_dir_list [current_project]

if { $g_useBlockDesign eq "Y" } {
update_ip_catalog -rebuild
	# if { [catch {source ${root_dir}/shell/gen_shell.tcl}] } {
		# puterrors "Shell generation process failed, terminating ..."
		# exit 1
	# }
	source ${root_dir}/shell/gen_shell.tcl
}	

####################################################
# GENERATE TOP FILE
####################################################
putmeeps "Generating the RTL top file ..."
source $g_root_dir/tcl/gen_top.tcl


####################################################
# MAIN FLOW
####################################################
set g_top_name ${g_project_name}_top
set top_module "$root_dir/src/${g_top_name}.sv"
set src_files [glob ${root_dir}/src/*]
add_files ${src_files}
# Add Constraint files to project
add_files -fileset [get_filesets constrs_1] "$root_dir/xdc/${g_board_part}/${g_project_name}_timing_${g_board_part}.xdc"
add_files -fileset [get_filesets constrs_1] "$root_dir/xdc/${g_board_part}/${g_project_name}_ila_${g_board_part}.xdc"
add_files -fileset [get_filesets constrs_1] "$root_dir/xdc/${g_board_part}/${g_project_name}_${g_board_part}.xdc"
set_property target_language Verilog [current_project]
source $root_dir/tcl/gen_runs.tcl

# system_top is the top module in the meep_shell project. It may change if we want
set_property top $g_top_name [current_fileset]

if { [catch {source $root_dir/accelerator/meep_shell/tcl/project_options.tcl} ErrorMessage] } {
	puterrors "File project_options.tcl has not been loaded"
	puterrors "$ErrorMessage"
} else {
	putmeeps "File project_options.tcl loaded"
}

## TODO: load the accelerator xdc file if it exists

set acc_xdc_file $g_accel_dir/meep_shell/xdc/${EAname}.xdc

if {[file exists $acc_xdc_file]} {
	add_files -fileset [get_filesets constrs_1] "$acc_xdc_file"
}

# Sanity checks
update_ip_catalog -rebuild
update_compile_order -fileset sources_1


# Set the incremental flow by default
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs synth_1]
set_property write_incremental_synth_checkpoint false [get_runs synth_1]

putmeeps "Writing project tcl ..."

#source $root_dir/tcl/gen_bitstream.tcl
write_project_tcl -force -all_properties -dump_project_info -quiet -verbose "${root_dir}/gen_system.tcl"
putmeeps "Cleaning up..."
file delete -force ${g_project_name}_def_val.txt
file delete -force ${g_project_name}_dump.txt
putmeeps "Done"
putcolors "Project generation ended successfully" $GREEN
exit
