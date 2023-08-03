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


#script_version 1 
set g_vivado_version [version -short]
set g_board_part u55c
set g_fpga_part xc${g_board_part}-fsvh2892-2L-e
set g_project_name system      
set g_root_dir    [pwd]                     
set g_project_dir ${g_root_dir}/project    
set g_accel_dir ${g_root_dir}/accelerator
set g_design_name ${g_project_name}       
set g_top_module  ${g_root_dir}/src/${g_project_name}_top.sv
set g_useBlockDesign Y 	  
set g_rtl_ext sv 	 
set g_number_of_jobs 8				  

#################################################################
# This list the shell capabilities. Add more interfaces when they 
# are ready to be implemented. XDC FPGA Board file could be used.
#################################################################
set ShellInterfacesList [list PCIE DDR4 HBM AURORA ETHERNET UART JTAG BROM BRAM SLV_AXI] 

## TODO: Add JTAG?
## List here the physical interfaces. Lowercase as they are connected
## to file names. 
set PortInterfacesList  [list pcie ddr4 aurora ethernet uart ]
set PCIeDMA "yes"

##################################################################
# Enable debug messages
##################################################################
set DebugEnable "False"

# u200 has not the same FPGA naming as u280, u55c or vcu128
if { $g_board_part == "u200" }  {
   set g_fpga_part "xcu200-fsgd2104-2-e"
   set pcieBlockLoc "X1Y2"
   set BOARD_FREQ "156.250"
} else {
   set pcieBlockLoc "PCIE4C_X1Y0"
   set BOARD_FREQ "100.000"
}

if { "$g_board_part" eq "u55c" } {
	set HBM_AXI_LABEL "_8HI"
} else {
	set HBM_AXI_LABEL ""
}


if { $g_board_part == "u200"} { 
    
	set ddr_freq "3334"
	set FREQ_HZ  "300000000" 
    set ddr_part "MTA18ASF2G72PZ-2G4"

} elseif { $g_board_part == "u280" } {

	# Placeholders, need to be reviewed
	set ddr_freq "3334"
	set FREQ_HZ "100000000"


} elseif { $g_board_part == "vcu128"} {

}
  


