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


set ETHClkNm   [dict get $ETHentry SyncClk Label]
set ETHFreq    [dict get $ETHentry SyncClk Freq]
set ETHClkName [dict get $ETHentry SyncClk Name]
set ETHintf    [dict get $ETHentry IntfLabel]

set ETHaddrWidth [dict get $ETHentry AxiAddrWidth]
set ETHdataWidth [dict get $ETHentry AxiDataWidth]
set ETHidWidth   [dict get $ETHentry AxiIdWidth]
set ETHUserWidth [dict get $ETHentry AxiUserWidth]

set ETHirq [dict get $ETHentry IRQ]

putdebugs "ETHClkNm     $ETHClkNm    "
putdebugs "ETHFreq      $ETHFreq     "
putdebugs "ETHClkName   $ETHClkName  "
putdebugs "ETHintf      $ETHintf     "
putdebugs "ETHaddrWidth $ETHaddrWidth"
putdebugs "ETHdataWidth $ETHdataWidth"
putdebugs "ETHidWidth   $ETHidWidth  "
putdebugs "ETHUserWidth $ETHUserWidth"
putdebugs "ETHirq       $ETHirq"

### Initialize the IPs
putmeeps "Packaging ETH IP..."
exec vivado -mode batch -nolog -nojournal -notrace -source $g_root_dir/ip/10GbEthernet/tcl/gen_project.tcl -tclargs $g_board_part
putmeeps "... Done."
update_ip_catalog -rebuild

source $g_root_dir/ip/10GbEthernet/tcl/ip_properties.tcl
create_bd_cell -type ip -vlnv meep-project.eu:MEEP:MEEP_10Gb_Ethernet:$g_ip_version MEEP_10Gb_Ethernet_0

# ## This might be hardcoded to the IP AXI bus width parameters until 
# ## we can back-propagate them to the Ethernet IP. 512,64,6

  set eth_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $ETHintf]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH $ETHaddrWidth \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH $ETHdataWidth \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH $ETHidWidth \
   CONFIG.MAX_BURST_LENGTH {64} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $eth_axi


create_bd_port -dir I -from 3 -to 0 -type data qsfp_4x_grx_n
create_bd_port -dir I -from 3 -to 0 -type data qsfp_4x_grx_p

create_bd_port -dir O -from 3 -to 0 -type data qsfp_4x_gtx_n
create_bd_port -dir O -from 3 -to 0 -type data qsfp_4x_gtx_p

create_bd_port -dir I -type clk -freq_hz 100000000 qsfp_ref_clk_n
create_bd_port -dir I -type clk -freq_hz 100000000 qsfp_ref_clk_p

connect_bd_net [get_bd_ports qsfp_ref_clk_p] [get_bd_pins MEEP_10Gb_Ethernet_0/qsfp_refck_clk_p]
connect_bd_net [get_bd_ports qsfp_ref_clk_n] [get_bd_pins MEEP_10Gb_Ethernet_0/qsfp_refck_clk_n]

connect_bd_net [get_bd_ports qsfp_4x_grx_n] [get_bd_pins MEEP_10Gb_Ethernet_0/qsfp_4x_grx_n]
connect_bd_net [get_bd_ports qsfp_4x_grx_p] [get_bd_pins MEEP_10Gb_Ethernet_0/qsfp_4x_grx_p]

connect_bd_net [get_bd_ports qsfp_4x_gtx_n] [get_bd_pins MEEP_10Gb_Ethernet_0/qsfp_4x_gtx_n]
connect_bd_net [get_bd_ports qsfp_4x_gtx_p] [get_bd_pins MEEP_10Gb_Ethernet_0/qsfp_4x_gtx_p]


connect_bd_net [get_bd_pins MEEP_10Gb_Ethernet_0/s_axi_clk] [get_bd_pins rst_ea_$ETHClkNm/slowest_sync_clk]
connect_bd_net [get_bd_pins rst_ea_$ETHClkNm/peripheral_aresetn] [get_bd_pins MEEP_10Gb_Ethernet_0/s_axi_resetn]
# Make External avoids passing the signal width to this point. The bus is created automatically
make_bd_pins_external  [get_bd_pins MEEP_10Gb_Ethernet_0/intc]
set_property name $ETHirq [get_bd_ports intc_0]
connect_bd_intf_net [get_bd_intf_ports $ETHintf] [get_bd_intf_pins MEEP_10Gb_Ethernet_0/S_AXI]

save_bd_design
## Create the Shell interface to the RTL
## CAUTION: The user can't specify USER, QOS and REGION signal for this interface
## This means those signals can't be in the module definition file


### Set Base Addresses to peripheral
# ETH
set ETHbaseAddr [dict get $ETHentry BaseAddr]

## Ethernet address space is 512K as the highest address. 
## TODO: Maybe it should be hardcoded

set ETHMemRange [expr {2**$ETHaddrWidth/1024}]

putdebugs "Base Addr ETH: $ETHbaseAddr"
putdebugs "Mem Range ETH: $ETHMemRange"

assign_bd_address [get_bd_addr_segs {MEEP_100Gb_Ethernet_0/S_AXI/reg0 }]

# set_property offset $ETHbaseAddr [get_bd_addr_segs {MEEP_100Gb_Ethernet_0/S_AXI/reg0 }]
# set_property range ${ETHMemRange}K [get_bd_addr_segs {MEEP_100Gb_Ethernet_0/S_AXI/reg0 }]


save_bd_design

