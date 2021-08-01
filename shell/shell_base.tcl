



namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

puts "The shell tcl will be sourced from ${script_folder}"

source tcl/environment.tcl

set shell_root $g_root_dir
set bdName "meep_shell"
set shell_dir "$g_project_dir/$bdName"
set shellBdFile "${bdName}.bd"

if { [file exists $g_root_dir/$shell_dir/$shellBdFile] > 0 } {
puts "BLOCK DESIGN EXISTS, REMOVING"
export_ip_user_files -of_objects  [get_files $g_root_dir/$shell_dir/$shellBdFile] -no_script -reset -force -quiet
remove_files  $g_root_dir/$shell_dir/$shellBdFile
}

create_bd_design -dir $g_project_dir $bdName
#update_ip_catalog -rebuild

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}


##################################################################
# DESIGN PROCs
##################################################################

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  source $g_root_dir/tcl/shell_env.tcl


  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj 
  
  # Restore current instance
  current_bd_instance $oldCurInst
  
}
# End of create_root_design()  