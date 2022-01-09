namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

putmeeps "The shell tcl will be sourced from ${script_folder}"

source tcl/environment.tcl
source $g_root_dir/tcl/vivado_iptable.tcl

set shell_root $g_root_dir
set bdName "meep_shell"
set shell_dir "$g_project_dir/$bdName"
set shellBdFile "${bdName}.bd"

if { [file exists $g_root_dir/$shell_dir/$shellBdFile] > 0 } {
putmeeps "BLOCK DESIGN EXISTS, REMOVING"
export_ip_user_files -of_objects  [get_files $g_root_dir/$shell_dir/$shellBdFile] -no_script -reset -force -quiet
remove_files  $g_root_dir/$shell_dir/$shellBdFile
}

create_bd_design -dir $g_project_dir $bdName
#update_ip_catalog -rebuild

