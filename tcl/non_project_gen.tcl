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


cd e:/git_repo/fpga_shell

source tcl/gen_meep.tcl
read_verilog ./src/system_top.sv
set_property part xcu280-fsvh2892-2L-e [current_project]

read_bd project/meep_shell/meep_shell.bd
set_property synth_checkpoint_mode None [get_files meep_shell.bd]
upgrade_ip [get_ips]
generate_target -force all [get_files meep_shell.bd]
synth_desing -top system_top

