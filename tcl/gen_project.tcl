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
# Check if script is running in correct Vivado version.
################################################################
set current_vivado_version [version -short]

if { [string first $g_vivado_version $current_vivado_version] == -1 } {
    puts ""
    catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR"\
	"This script was generated using Vivado <$g_vivado_version> and is being\
	run in <$current_vivado_version> of Vivado. Please run the script in Vivado\
	<$scripts_vivado_version> then open the design in Vivado\
	<$current_vivado_version>. Upgrade the design by running \"Tools => \
	Report => Report IP Status...\", then run write_bd_tcl to create an updated\
	script."}

    return 1
}

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
# Set project properties
set obj [current_project]
#set_property -name "board_part" -value "xilinx.com:au280:part0:1.1" -objects $obj

#MEEP Phase 2 part
#set_property -name "target_part" -value "xcvu47p-fsvh2892-2L-e" -objects $obj

# CHANGE DESIGN NAME HERE
variable design_name
set design_name $g_project_name

# This needs to be defined before creating the block design 
set ip_dir_list [get_property ip_repo_paths [current_project]]
lappend ip_dir_list $root_dir/ip
set_property  ip_repo_paths  $ip_dir_list [current_project]

if { $g_useBlockDesign eq "Y" } {
update_ip_catalog -rebuild
	# if { [catch {source ${root_dir}/tcl/gen_shell.tcl}] } {
		# puterrors "Shell generation process failed, terminating ..."
		# exit 1
	# }
	source ${root_dir}/tcl/gen_shell.tcl
}	
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
if { [catch {source $root_dir/accelerator/meep_shell/tcl/project_options.tcl}]} {
	puterrors "File project_options.tcl has not been loaded"
} else {
	putmeeps "File project_options.tcl loaded"
}

# The accelerator needs to define its own repo paths and the main project ip_path can be overwritten. 
# Need to define it again
set ip_dir_list [get_property ip_repo_paths [current_project]]
lappend ip_dir_list $root_dir/ip
	
set_property  ip_repo_paths  $ip_dir_list [current_project]

# This is how we call the top module in the meep_shell project. It may change if we want
set_property top $g_top_name [current_fileset]

putcolors "Project generation ended successfully" $GREEN

#source $root_dir/tcl/gen_bitstream.tcl
write_project_tcl -force -all_properties -dump_project_info -quiet -verbose "${root_dir}/gen_system.tcl"
putmeeps "Cleaning up..."
file delete -force ${g_project_name}_def_val.txt
file delete -force ${g_project_name}_dump.txt
putmeeps "Done"
exit
