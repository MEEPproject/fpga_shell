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


set ETHFreq    [dict get $ETHentry SyncClk Freq]
set ETHClkName [dict get $ETHentry ClkName]
set ETHRstName [dict get $ETHentry RstName]
set ETHintf    [dict get $ETHentry IntfLabel]
set ETHqsfp    [dict get $ETHentry qsfpPort]

set ETHaddrWidth [dict get $ETHentry AxiAddrWidth]
set ETHdataWidth [dict get $ETHentry AxiDataWidth]
set ETHidWidth   [dict get $ETHentry AxiIdWidth]
set ETHUserWidth [dict get $ETHentry AxiUserWidth]

set ETHirq [dict get $ETHentry IRQ]

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
exec vivado -mode batch -nolog -nojournal -notrace -source $g_root_dir/ip/10GbEthernet/tcl/gen_project.tcl -tclargs $g_board_part $ETHqsfp
putmeeps "... Done."
update_ip_catalog -rebuild


if { $ETHqsfp == "qsfp0" } {
        set QSFP "0"
	set PortList [lappend PortList $g_Eth0_file]
} elseif { $ETHqsfp == "qsfp1" } {
        set QSFP "1"
	set PortList [lappend PortLIst $g_Eth1_file]
} else {
	set QSFP "PCIe"
}

source $g_root_dir/ip/10GbEthernet/tcl/ip_properties.tcl
# Create a list of IP parameters to pass it to the hierarchy generation procedure
set eth_ip [list $ETHqsfp $g_ip_version ]

# Load the hierarchy procedure and call it
source $g_root_dir/shell/hier_ethernet.tcl
set EthHierName "Ethernet10Gb_${ETHqsfp}"
create_hier_cell_Ethernet $TopCell "${EthHierName}" $eth_ip
save_bd_design

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



#create_bd_port -dir I -from 0 -to 0 -type data qsfp_1x_grx_n
#create_bd_port -dir I -from 0 -to 0 -type data qsfp_1x_grx_p

#create_bd_port -dir O -from 0 -to 0 -type data qsfp_1x_gtx_n
#create_bd_port -dir O -from 0 -to 0 -type data qsfp_1x_gtx_p

#create_bd_port -dir I -type clk -freq_hz 100000000 qsfp_ref_clk_n
#create_bd_port -dir I -type clk -freq_hz 100000000 qsfp_ref_clk_p

if { $ETHqsfp != "pcie"} {

set ipClock "eth_gt_user_clock"
set ipRst "eth_gt_rstn"
set ipLocked "locked"

set EthHierName "Ethernet10Gb_${ETHqsfp}"

set ipClockPin [get_bd_pins ${EthHierName}/$ipClock]

make_bd_intf_pins_external  [get_bd_intf_pins ${EthHierName}/${ETHqsfp}_refclk]
set_property name qsfp${QSFP}_ref [get_bd_intf_ports ${ETHqsfp}_refclk_0]

make_bd_intf_pins_external  [get_bd_intf_pins ${EthHierName}/${ETHqsfp}_1x]
set_property name qsfp${QSFP}_1x [get_bd_intf_ports ${ETHqsfp}_1x_0]

set_property CONFIG.FREQ_HZ 1611328125 [get_bd_intf_ports /qsfp${QSFP}_ref]

create_bd_port -dir O qsfp${QSFP}_oe_b
create_bd_port -dir O qsfp${QSFP}_fs
connect_bd_net [get_bd_ports qsfp${QSFP}_oe_b] [get_bd_pins ${EthHierName}/${ETHqsfp}_oe_b]
connect_bd_net [get_bd_ports qsfp${QSFP}_fs] [get_bd_pins ${EthHierName}/${ETHqsfp}_fs]

connect_bd_net $APBClockPin [get_bd_pins ${EthHierName}/init_clk]
connect_bd_net $MMCMLockedPin [get_bd_pins ${EthHierName}/$ipLocked]

set RstPinIP   [get_bd_pins ${EthHierName}/$ipRst]  

} else {

	set ipClock "clock"
	set ipClockPin [get_bd_pins ${EthHierName}/$ipClock]
	#set ipRst "resetn"
	set ipRst "async_resetn"
	set ipLocked "async_resetn"

	connect_bd_net $pcie_clk_pin $ipClockPin
	connect_bd_net $pcie_rst_pin [get_bd_pins ${EthHierName}/$ipRst]

	set RstPinIP $pcie_rst_pin

}
# Make External avoids passing the signal width to this point. The bus is created automatically
create_bd_port -dir O -from 1 -to 0 -type intr $ETHirq
connect_bd_net [get_bd_ports $ETHirq] [get_bd_pins ${EthHierName}/eth_dma_irq]

connect_bd_intf_net [get_bd_intf_ports ${ETHintf}] -boundary_type upper [get_bd_intf_pins ${EthHierName}/eth_dma_axi_lite]


create_bd_port -dir O -type clk $ETHClkName
connect_bd_net [get_bd_ports ${ETHClkName}] [get_bd_pins ${EthHierName}/eth_gt_user_clock]

create_bd_port -dir O -type rst $ETHRstName
connect_bd_net [get_bd_ports ${ETHRstName}] [get_bd_pins ${EthHierName}/eth_gt_rstn]


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

assign_bd_address [get_bd_addr_segs {${EthHierName}/s_axi_lite/reg0 }]

# Open an HBM Channel so the Ethernet DMA gets to the main memory

#set_property -dict [list CONFIG.USER_CLK_SEL_LIST1 {AXI_30_ACLK} CONFIG.USER_SAXI_30 {true}] [get_bd_cells hbm_0]
#create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_eth${QSFP}
#create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dwidth_converter:2.1 axi_dwidth_converter_eth${QSFP}

#connect_bd_intf_net [get_bd_intf_pins ${EthHierName}/M_AXI] [get_bd_intf_pins axi_dwidth_converter_eth${QSFP}/S_AXI]
#connect_bd_intf_net [get_bd_intf_pins axi_dwidth_converter_eth${QSFP}/M_AXI] [get_bd_intf_pins axi_protocol_converter_eth${QSFP}/S_AXI] 
#connect_bd_intf_net [get_bd_intf_pins axi_protocol_converter_eth${QSFP}/M_AXI] [get_bd_intf_pins hbm_0/SAXI_30${HBM_AXI_LABEL}]

#connect_bd_net [get_bd_pins ${EthHierName}/gt_clock] [get_bd_pins axi_protocol_converter_eth${QSFP}/aclk]
#connect_bd_net [get_bd_pins ${EthHierName}/gt_clock] [get_bd_pins axi_dwidth_converter_eth${QSFP}/s_axi_aclk]
#connect_bd_net [get_bd_pins hbm_0/AXI_30_ACLK] [get_bd_pins ${EthHierName}/gt_clock]
#connect_bd_net [get_bd_pins ${EthHierName}/gt_rstn] [get_bd_pins hbm_0/AXI_30_ARESET_N]

#connect_bd_net [get_bd_pins ${EthHierName}/gt_rstn] [get_bd_pins axi_protocol_converter_eth${QSFP}/aresetn]
#connect_bd_net [get_bd_pins ${EthHierName}/gt_rstn] [get_bd_pins axi_dwidth_converter_eth${QSFP}/s_axi_aresetn]

# set_property offset $ETHbaseAddr [get_bd_addr_segs {MEEP_100Gb_Ethernet_0/S_AXI/reg0 }]
# set_property range ${ETHMemRange}K [get_bd_addr_segs {MEEP_100Gb_Ethernet_0/S_AXI/reg0 }]

#set_property name qsfp${QSFP}_1x_grx_p [get_bd_ports qsfp_1x_grx_p]
#set_property name qsfp${QSFP}_1x_grx_n [get_bd_ports qsfp_1x_grx_n]

#set_property name qsfp${QSFP}_1x_gtx_p [get_bd_ports qsfp_1x_gtx_p]
#set_property name qsfp${QSFP}_1x_gtx_n [get_bd_ports qsfp_1x_gtx_n]

#set_property name qsfp${QSFP}_ref_clk_p [get_bd_ports qsfp_ref_clk_p]
#set_property name qsfp${QSFP}_ref_clk_n [get_bd_ports qsfp_ref_clk_n]



save_bd_design
