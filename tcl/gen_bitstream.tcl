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


source [pwd]/tcl/environment.tcl

if { $::argc > 0 } {
 set g_roo_dir $::argv
 puts "Root directory is $g_root_dir"
} else {
 puts "Bad usage: this script needs an argument"
 exit -1
}


proc bitstream { g_root_dir } {

	file mkdir $g_root_dir/bitstream
	open_checkpoint $g_root_dir/dcp/implementation.dcp
	write_bitstream -force ${g_root_dir}/bitstream/system.bit
	write_debug_probes -no_partial_ltxfile -force $g_root_dir/bitstream/system.ltx
}

bitstream $g_root_dir

