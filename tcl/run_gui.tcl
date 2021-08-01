set thisDir [pwd]
source ./tcl/environment.tcl

puts "${thisDir}"

cd $g_project_dir
open_project ${g_project_name}.xpr
cd $g_root_dir


start_gui