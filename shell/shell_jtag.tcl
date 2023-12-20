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

# Author: Alexander Kropotov, BSC-CNS
# Date: 02.08.2023
# Description: 

set JTAGCkLabl [dict get $JTAGentry SyncClk Label]
set JTAGCkFreq [dict get $JTAGentry SyncClk Freq]
set JTAGCkName [dict get $JTAGentry SyncClk Name]
set JTAGLabl   [dict get $JTAGentry IntfLabel]
set JTAGMode   [dict get $JTAGentry Mode]

putmeeps "Instantiating JTAG interface $JTAGLabl in $JTAGMode mode"

set bscan_prim [ create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 bscan_prim ]
  set_property -dict [ list \
   CONFIG.C_DEBUG_MODE {7} \
   CONFIG.C_NUM_BS_MASTER {2} \
 ] $bscan_prim
set debug_hub  [ create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 debug_hub ]
connect_bd_intf_net [get_bd_intf_pins bscan_prim/m1_bscan] [get_bd_intf_pins debug_hub/S_BSCAN ]

if { $JTAGMode == "bscan" } {
  make_bd_intf_pins_external  [get_bd_intf_pins bscan_prim/m0_bscan]
  set_property name $JTAGLabl [get_bd_intf_ports m0_bscan_0]
} else {
  set bscan2jtag [ create_bd_cell -type ip -vlnv xilinx.com:ip:bscan_jtag:1.0 bscan2jtag ]
  connect_bd_intf_net [get_bd_intf_pins bscan_prim/m0_bscan] [get_bd_intf_pins bscan2jtag/S_BSCAN]
  make_bd_intf_pins_external  [get_bd_intf_pins bscan2jtag/M_JTAG]
  set_property name $JTAGLabl [get_bd_intf_ports M_JTAG_0]
}

putmeeps "Using $JTAGCkLabl clock = $JTAGCkFreq Hz ($JTAGCkName) as free-running clock for Debug Hub"
connect_bd_net [get_bd_pins debug_hub/clk] [get_bd_pins rst_ea_$JTAGCkLabl/slowest_sync_clk]

save_bd_design
