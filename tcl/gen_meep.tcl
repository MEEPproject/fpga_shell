#define_shell.tcl

namespace eval _tcl {
proc get_script_folder {} {
    set script_path [file normalize [info script]]
    set script_folder [file dirname $script_path]
    return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

source $script_folder/environment.tcl
source $g_root_dir/tcl/procedures.tcl

putmeeps "Environment loaded from ${script_folder}"

### TODO: Add catch to every source
putmeeps "Defining the shell environment file"
source $g_root_dir/tcl/define_shell.tcl
putmeeps "Generating the shell IPs ..."
source $g_root_dir/tcl/init_ips.tcl
putmeeps "Generating the RTL top file ..."
source $g_root_dir/tcl/gen_top.tcl
putmeeps "Creating the project ..."
source $g_root_dir/tcl/gen_project.tcl
