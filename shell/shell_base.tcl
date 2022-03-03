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

