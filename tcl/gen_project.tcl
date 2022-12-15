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

# Save the timing constraint file to be edited later for the different selectable IPs (GPIO, Ethernet)
# Hierarchy is fixed for the MEEP Shell. Each IP adds its own set of constraints to this file
set TimingConstrFile "$root_dir/xdc/${g_board_part}/${g_project_name}_timing_${g_board_part}.xdc"
set ILAConstrFile    "$root_dir/xdc/${g_board_part}/${g_project_name}_ila_${g_board_part}.xdc"
set BoardConstrFile  "$root_dir/xdc/${g_board_part}/${g_project_name}_${g_board_part}.xdc"

# Clean up from previous builds, and generate a new one
file delete -force $TimingConstrFile
set InitDate [ clock format [ clock seconds ] -format %d/%m/%Y ]
set InitTime [ clock format [ clock seconds ] -format %H:%M:%S ]
# Initialize the file
[Add2ConstrFileList $TimingConstrFile #$InitDate ]

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
add_files -fileset [get_filesets constrs_1] $TimingConstrFile
add_files -fileset [get_filesets constrs_1] $ILAConstrFile
add_files -fileset [get_filesets constrs_1] $BoardConstrFile
set_property target_language Verilog [current_project]
source $root_dir/tcl/gen_runs.tcl

# system_top is the top module in the meep_shell project. It may change if we want
set_property top $g_top_name [current_fileset]


# Placeholder for the EA IP directory list.
set ip_ea_dir [list]

if { [catch {source $root_dir/accelerator/meep_shell/tcl/project_options.tcl} ErrorMessage] } {
	puterrors "File project_options.tcl has not been loaded"
	puterrors "$ErrorMessage"
	return 1
} else {
	putmeeps "File project_options.tcl loaded"
}

## TODO: load the accelerator xdc file if it exists

set acc_xdc_file $g_accel_dir/meep_shell/xdc/${EAname}.xdc

if {[file exists $acc_xdc_file]} {
	add_files -fileset [get_filesets constrs_1] "$acc_xdc_file"
}

# Update the list of IP directories. The EA creates a list
# of directories under ip_ea_dir variable.
# TODO: Document this.
set ip_dir_list [get_property ip_repo_paths [current_project]]
set ip_dir_list [concat $ip_dir_list $ip_ea_dir]
set_property  ip_repo_paths  $ip_dir_list [current_project]

## Add a list of EA files if the EA has created the ea_flist variable

if { [info exists g_ea_flist] } {
    putcolors "Adding EA source files ..." $CYAN
    add_files ${g_ea_flist}

}

# Add a list of xci files from an EA list if it exists

if { [info exists g_ip_list] } {
    putcolors "Adding the EA IPs ..." $CYAN

    foreach oneIP $g_ip_list {
        if { [catch {import_ip $oneIP} ErrorMessage] } {
                puterrors "IP $oneIP has not been added"
                puterrors "$ErrorMessage"
                return 1
        } else {
                putcolors "IP $oneIP added" $CYAN
        }
    }
}

# Add block designs from an EA list if it exists

if { [info exists g_bd_list] } {
    putcolors "Adding the EA BDs ..." $CYAN

    foreach oneBD $g_bd_list {
        if { [catch {add_files ${oneBD}} ErrorMessage] } {
                puterrors "BD $oneBD has not been added"
                puterrors "$ErrorMessage"
                return 1
        } else {                
                putcolors "BD $oneBD added" $CYAN
        }
    }
}


### Apply a list patches of patches if it exists
# The patch list is a list of paths to block design tcl files.
# The definition of this list is EA's responsability, that needs
# to match the "g_patch_list" variable name, and use correct paths
# It can be done under $accelerator_path/meep_shell/tcl/project_options.tcl

if { [info exists g_patch_list] } {
    putcolors "Applying shell patches ..." $CYAN

    foreach patch $g_patch_list {
        if { [catch {source $patch} ErrorMessage] } {
                puterrors "Patch $patch has not been loaded"
                puterrors "$ErrorMessage"
                return 1
        } else {
                putcolors "Patch $patch applied" $CYAN
        }
    }
    save_bd_design
}

validate_bd_design
save_bd_design

# Sanity checks
update_ip_catalog -rebuild
update_compile_order -fileset sources_1


# Set the incremental flow by default
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs synth_1]
set_property write_incremental_synth_checkpoint false [get_runs synth_1]
# Use a tcl hook to update the ROM contents
add_files -fileset utils_1 -norecurse $root_dir/tcl/pre_synth.tcl
set_property STEPS.SYNTH_DESIGN.TCL.PRE [get_files ${root_dir}/tcl/pre_synth.tcl -of [get_fileset utils_1] ] [get_runs synth_1]

putmeeps "Writing project tcl ..."

#source $root_dir/tcl/gen_bitstream.tcl
write_project_tcl -force -all_properties -dump_project_info -quiet -verbose "${root_dir}/gen_system.tcl"
putmeeps "Cleaning up..."
file delete -force ${g_project_name}_def_val.txt
file delete -force ${g_project_name}_dump.txt
putmeeps "Done"
putcolors "Project generation ended successfully" $GREEN
exit
