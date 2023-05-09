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


# This tcl handles both Aurora modes, RAW and DMA. We use the fact that the two options differ
# only in the "dma" or "raw" part of the string, even for the PATH of the IPs. 

set AuroraClkNm  [dict get $AURORAentry SyncClk Label]
set AuroraFreq   [dict get $AURORAentry SyncClk Freq]
set Auroraname   [dict get $AURORAentry SyncClk Name]
set Auroraintf   [dict get $AURORAentry IntfLabel]
set AuroraMode   [dict get $AURORAentry Mode]
# set AuroraUsrClk [dict get $AURORAentry UsrClk]
set AuroraQSFP   [dict get $AURORAentry qsfpPort]

set AuroraaddrWidth [dict get $$AURORAentry AxiAddrWidth]
set AuroradataWidth [dict get $$AURORAentry AxiDataWidth]
set AuroraidWidth   [dict get $$AURORAentry AxiIdWidth]
set AuroraUserWidth [dict get $$AURORAentry AxiUserWidth]

set AuroraIP ""

if { $AuroraMode == "DMA" } {

	set AuroraMode "dma"

} elseif { $AuroraMode == "RAW" } {

       set AuroraMode "raw"
}

if { $AuroraQSFP == "qsfp0" } {
        set QSFP "0"
        set PortList [lappend PortList $g_aurora0_file]
} else {
        set QSFP "1"
        set PortList [lappend PortLIst $g_aurora1_file]
}



### Initialize the IPs
putmeeps "Packaging Aurora IP..."
exec vivado -mode batch -nolog -nojournal -notrace -source ./ip/aurora_${AuroraMode}/tcl/gen_project.tcl -tclargs $g_board_part
putmeeps "... Done."
update_ip_catalog -rebuild

source $g_root_dir/ip/aurora_${AuroraMode}/tcl/project_options.tcl

#TODO: The Numbering of the added cells need to be dependant on the number of QSFP interfaces the user has defined

create_bd_cell -type ip -vlnv meep-project.eu:MEEP:MEEP_aurora_${AuroraMode}:$g_ip_version aurora_${AuroraMode}_${QSFP}

# TODO: Again, there are several naming possibilities depending on the selected combination of QSFP devices
make_bd_intf_pins_external  [get_bd_intf_pins aurora_${AuroraMode}_${QSFP}/gt_refclk]

# Leverage from the APBCLK to connect the init CLK, as we know the former is always between 50-100MHz
connect_bd_net [get_bd_pins aurora_${AuroraMode}_${QSFP}/INIT_CLK] $APBClockPin
# Active-high reset
connect_bd_net [get_bd_pins rst_ea_${AuroraClkNm}/peripheral_reset] [get_bd_pins aurora_${AuroraMode}_${QSFP}/RESET]

# Connect to ground the self-testing capabilities. 
# TODO: Add GPIO connections for these pins
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 aurora_gnd
set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells aurora_gnd]



if { $AuroraMode == "dma" } {

connect_bd_net [get_bd_pins rst_ea_${AuroraClkNm}/slowest_sync_clk] [get_bd_pins aurora_${AuroraMode}_${QSFP}/S_AXI_LITE_DMA_ACLK] 

### Set Base Addresses to peripheral
# Aurora
set AurorabaseAddr [dict get $AURORAentry BaseAddr]
set AuroraMemRange [expr {2**$AuroraaddrWidth/1024}]

putdebugs "Base Addr Aurora: $AurorabaseAddr"
putdebugs "Mem Range Aurora: $AuroraMemRange"


# set_property offset $AurorabaseAddr [get_bd_addr_segs $Auroraintf/SEG_aurora_dma_0_Mem0]
# set_property range ${AuroraMemRange}K [get_bd_addr_segs $Auroraintf/SEG_aurora_dma_0_Mem0]

} elseif { $AuroraMode == "raw" } {

    connect_bd_net [get_bd_pins aurora_${AuroraMode}_${QSFP}/SIMULATE_FRAME_CHECK] [get_bd_pins aurora_gnd/dout]
    connect_bd_net [get_bd_pins aurora_${AuroraMode}_${QSFP}/SIMULATE_FRAME_GEN]   [get_bd_pins aurora_gnd/dout]
    connect_bd_net [get_bd_pins aurora_${AuroraMode}_${QSFP}/DATA_INJ]             [get_bd_pins aurora_gnd/dout]

	make_bd_intf_pins_external  [get_bd_intf_pins aurora_${AuroraMode}_${QSFP}/S_USER_AXIS_UI_TX]
	
	# REQUIREMENT: The csv definition file can use only one intf name but
	# the ea wrapper module need to extend the name with _rx and _tx
	set_property name ${Auroraintf}_tx [get_bd_intf_ports S_USER_AXIS_UI_TX_0]

	make_bd_intf_pins_external  [get_bd_intf_pins aurora_${AuroraMode}_${QSFP}/M_USER_AXIS_UI_RX]
	set_property name ${Auroraintf}_rx [get_bd_intf_ports M_USER_AXIS_UI_RX_0]
	# TODO: RX and TX labels can create confussion: TX is injected to the core to be 
	# transmitted. RX is ouput from the core and served to the user logic
	
 	# set aurora_usr_clk $AuroraUsrClk	
	make_bd_pins_external  [get_bd_pins aurora_${AuroraMode}_${QSFP}/USER_CLK_OUT]
	# set_property name $AuroraUsrClk [get_bd_ports USER_CLK_OUT_0]


}




