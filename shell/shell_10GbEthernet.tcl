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

set ETHClkLab  [dict get $ETHentry SyncClk Label]
set ETHFreq    [dict get $ETHentry SyncClk Freq]
set ETHClkIf   [dict get $ETHentry SyncClk Name]
set ETHintf    [dict get $ETHentry IntfLabel]
set ETHqsfp    [dict get $ETHentry qsfpPort]
set ETHdmaMem  [dict get $ETHentry dmaMem]
set EthHBMCh   [dict get $ETHentry HBMChan]
set EthAxi     [dict get $ETHentry AxiIntf]

set ETHaddrWidth [dict get $ETHentry AxiAddrWidth]
set ETHdataWidth [dict get $ETHentry AxiDataWidth]
set ETHidWidth   [dict get $ETHentry AxiIdWidth]
set ETHUserWidth [dict get $ETHentry AxiUserWidth]

set ETHirq [dict get $ETHentry IRQ]

putdebugs "ETHClkLab    $ETHClkLab   "
putdebugs "ETHFreq      $ETHFreq     "
putdebugs "ETHClkIf     $ETHClkIf    "
putdebugs "ETHintf      $ETHintf     "
putdebugs "ETHaddrWidth $ETHaddrWidth"
putdebugs "ETHdataWidth $ETHdataWidth"
putdebugs "ETHidWidth   $ETHidWidth  "
putdebugs "ETHUserWidth $ETHUserWidth"
putdebugs "ETHirq       $ETHirq"

### Initialize the IPs
putmeeps "Packaging ETH IP..."
exec make -C "$g_root_dir/ip/10GbEthernet" $ETHqsfp FPGA_BOARD=$g_board_part
putmeeps "... Done."
update_ip_catalog -rebuild


if { $ETHqsfp == "qsfp0" } {
        set QSFP "0"
	set PortList [lappend PortList $g_Eth0_file]
} elseif { $ETHqsfp == "qsfp1" } {
        set QSFP "1"
	set PortList [lappend PortList $g_Eth1_file]
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

## Add timing constraints to the timing constrains file
set dma_mm2s_irq_pin "meep_shell_inst/${EthHierName}/axi_dma_0/U0/I_AXI_DMA_REG_MODULE/GEN_MM2S_REGISTERS.GEN_INTROUT_ASYNC.PROC_REG_INTR2LITE/GENERATE_LEVEL_P_S_CDC.SINGLE_BIT.CROSS_PLEVEL_IN2SCNDRY_s_level_out_d4/C"
set dma_s2mm_irq_pin "meep_shell_inst/${EthHierName}/axi_dma_0/U0/I_AXI_DMA_REG_MODULE/GEN_S2MM_REGISTERS.GEN_INTROUT_ASYNC.PROC_REG_INTR2LITE/GENERATE_LEVEL_P_S_CDC.SINGLE_BIT.CROSS_PLEVEL_IN2SCNDRY_s_level_out_d4/C"

set dma_mm2s_constr "set_max_delay -from \[get_pins $dma_mm2s_irq_pin\] 3.0"
set dma_s2mm_constr "set_max_delay -from \[get_pins $dma_s2mm_irq_pin\] 3.0"

set ConstrList [list $dma_mm2s_constr $dma_s2mm_constr ]

[Add2ConstrFileList $TimingConstrFile $ConstrList]

  set EthAxiProt  [string replace $EthAxi   [string first "-" $EthAxi] end]
  set EthAxiWidth [string replace $EthAxi 0 [string first "-" $EthAxi]    ]
  set eth_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $ETHintf]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {12} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH $EthAxiWidth \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {256} \
   CONFIG.NUM_READ_THREADS {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {256} \
   CONFIG.NUM_WRITE_THREADS {16} \
   CONFIG.PROTOCOL $EthAxiProt \
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

connect_bd_net $EthInitClkPin [get_bd_pins ${EthHierName}/init_clk]
connect_bd_net $MMCMLockedPin [get_bd_pins ${EthHierName}/$ipLocked]

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
# Make External avoids passing the signal width at this point. The bus is created automatically
create_bd_port -dir O -from 1 -to 0 -type intr $ETHirq
connect_bd_net [get_bd_ports $ETHirq] [get_bd_pins ${EthHierName}/eth_dma_irq]

connect_bd_intf_net [get_bd_intf_ports ${ETHintf}] -boundary_type upper [get_bd_intf_pins ${EthHierName}/eth_dma_axi_lite]

# Connect the defined ethernet CLK & RST to the DMA AXI IP, and also forward them to the EA
connect_bd_net [get_bd_pins ${EthHierName}/eth_dma_clk]   [get_bd_pins rst_ea_$ETHClkLab/slowest_sync_clk]
connect_bd_net [get_bd_pins ${EthHierName}/eth_dma_arstn] [get_bd_pins rst_ea_$ETHClkLab/peripheral_aresetn]

# TODO: This reset maybe need to be ORed with the External User reset
connect_bd_net [get_bd_ports resetn] [get_bd_pins ${EthHierName}/eth_ext_rstn]

set_property CONFIG.ASSOCIATED_BUSIF [get_property CONFIG.ASSOCIATED_BUSIF [get_bd_ports /$ETHClkIf]]$ETHintf: [get_bd_ports /$ETHClkIf]

save_bd_design
## Create the Shell interface to the RTL
## CAUTION: The user can't specify USER, QOS and REGION signal for this interface
## This means those signals can't be in the module definition file


### Set Base Addresses to peripheral
# ETH
set ETHbaseAddr [dict get $ETHentry BaseAddr]

## Ethernet address space is 512K as the highest address. 
## TODO: Maybe it should be hardcoded

# set ETHMemRange [expr {2**$ETHaddrWidth/1024}]

putdebugs "Base Addr ETH: $ETHbaseAddr"
# putdebugs "Mem Range ETH: $ETHMemRange"

# assign_bd_address [get_bd_addr_segs ${EthHierName}/axi_dma_0/S_AXI_LITE/Reg ]
# set_property offset $ETHbaseAddr [get_bd_addr_segs ${ETHintf}/SEG_axi_dma_0_Reg]
# set_property range $ETHMemRange [get_bd_addr_segs ${ETHintf}/SEG_axi_dma_0_Reg]


# Open an HBM Channel so the Ethernet DMA gets to the main memory

# if { $g_board_part == "u280" && [expr $EthHBMCh/16] != [expr $PCIeHBMCh/16] } {
#   putmeeps "Resolving not completely investegated HBM issue for board $g_board_part:"
#   putmeeps "probably $ETHrate Eth DMA is single channel ($EthHBMCh) connected to HBM stack [expr $EthHBMCh/16] switch,"
#   set EthHBMCh [formatHBMch [expr $PCIeHBMCh + 1]]
#   putmeeps "so moving it to channel $EthHBMCh, next to PCIe channel $PCIeHBMCh, please change it accordingly if it doesn't fit."
# }

set TxHBMCh [expr $EthHBMCh+0]
set RxHBMCh [expr $EthHBMCh+1]
set SgHBMCh [expr $EthHBMCh+2]

set_property -dict [list CONFIG.USER_SAXI_${TxHBMCh} {TRUE}] [get_bd_cells hbm_0]
set_property -dict [list CONFIG.USER_SAXI_${RxHBMCh} {TRUE}] [get_bd_cells hbm_0]
set_property -dict [list CONFIG.USER_SAXI_${SgHBMCh} {TRUE}] [get_bd_cells hbm_0]

connect_bd_intf_net [get_bd_intf_pins hbm_0/SAXI_${TxHBMCh}${HBM_AXI_LABEL}] [get_bd_intf_pins ${EthHierName}/m_axi_tx]
connect_bd_intf_net [get_bd_intf_pins hbm_0/SAXI_${RxHBMCh}${HBM_AXI_LABEL}] [get_bd_intf_pins ${EthHierName}/m_axi_rx]
connect_bd_intf_net [get_bd_intf_pins hbm_0/SAXI_${SgHBMCh}${HBM_AXI_LABEL}] [get_bd_intf_pins ${EthHierName}/m_axi_sg]

connect_bd_net [get_bd_pins hbm_0/AXI_${TxHBMCh}_ACLK] [get_bd_pins ${EthHierName}/eth_gt_user_clock]
connect_bd_net [get_bd_pins hbm_0/AXI_${RxHBMCh}_ACLK] [get_bd_pins ${EthHierName}/eth_gt_user_clock]
connect_bd_net [get_bd_pins hbm_0/AXI_${SgHBMCh}_ACLK] [get_bd_pins ${EthHierName}/eth_dma_clk]

connect_bd_net [get_bd_pins hbm_0/AXI_${TxHBMCh}_ARESET_N] [get_bd_pins ${EthHierName}/tx_rstn]
connect_bd_net [get_bd_pins hbm_0/AXI_${RxHBMCh}_ARESET_N] [get_bd_pins ${EthHierName}/rx_rstn]
connect_bd_net [get_bd_pins hbm_0/AXI_${SgHBMCh}_ARESET_N] [get_bd_pins ${EthHierName}/eth_dma_arstn]

# set_property offset $ETHbaseAddr [get_bd_addr_segs {MEEP_100Gb_Ethernet_0/S_AXI/reg0 }]
# set_property range ${ETHMemRange}K [get_bd_addr_segs {MEEP_100Gb_Ethernet_0/S_AXI/reg0 }]

save_bd_design
