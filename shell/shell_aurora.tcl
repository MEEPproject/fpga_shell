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
set AuroraClkIf  [dict get $AURORAentry SyncClk Name]
set Auroraintf   [dict get $AURORAentry IntfLabel]
set AuroraMode   [dict get $AURORAentry Mode]
# set AuroraUsrClk [dict get $AURORAentry UsrClk]
set AuroraQSFP   [dict get $AURORAentry qsfpPort]
set AuroradmaMem [dict get $AURORAentry dmaMem]
set AuroraHBMCh  [dict get $AURORAentry HBMChan]
set AuroraAXI    [dict get $AURORAentry AxiIntf]
set Aurorairq    [dict get $AURORAentry IRQ]


set AuroraaddrWidth [dict get $$AURORAentry AxiAddrWidth]
set AuroradataWidth [dict get $$AURORAentry AxiDataWidth]
set AuroraidWidth   [dict get $$AURORAentry AxiIdWidth]
set AuroraUserWidth [dict get $$AURORAentry AxiUserWidth]

set AuroraIP ""

if { $AuroraMode == "dma" } {
  set AurHierName "Aurora_${AuroraMode}_${AuroradmaMem}"
} elseif { $AuroraMode == "raw" } {
  set AurHierName "Aurora_${AuroraMode}"
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
exec vivado -mode batch -nolog -nojournal -notrace -source ./ip/aurora_${AuroraMode}/tcl/gen_project.tcl -tclargs $g_board_part $AuroraQSFP $AuroradmaMem $AuroraFreq $AuroraAXI
putmeeps "... Done."
update_ip_catalog -rebuild

source $g_root_dir/ip/aurora_${AuroraMode}/tcl/project_options.tcl

#TODO: The Numbering of the added cells need to be dependant on the number of QSFP interfaces the user has defined

create_bd_cell -type ip -vlnv meep-project.eu:MEEP:MEEP_aurora_${AuroraMode}:$g_ip_version ${AurHierName}

# Now all AXI properties are inhereted from the IP
make_bd_intf_pins_external [get_bd_intf_pins $AurHierName/s_axi]
set_property name $Auroraintf [get_bd_intf_ports s_axi_0]

create_bd_port -dir I -from 3 -to 0 -type data aur_qsfp_4x_grx_n
create_bd_port -dir I -from 3 -to 0 -type data aur_qsfp_4x_grx_p

create_bd_port -dir O -from 3 -to 0 -type data aur_qsfp_4x_gtx_n
create_bd_port -dir O -from 3 -to 0 -type data aur_qsfp_4x_gtx_p

create_bd_port -dir I -type clk aur_qsfp_ref_clk_n
create_bd_port -dir I -type clk aur_qsfp_ref_clk_p

connect_bd_net [get_bd_ports aur_qsfp_ref_clk_p] [get_bd_pins ${AurHierName}/qsfp_refck_clk_p]
connect_bd_net [get_bd_ports aur_qsfp_ref_clk_n] [get_bd_pins ${AurHierName}/qsfp_refck_clk_n]

connect_bd_net [get_bd_ports aur_qsfp_4x_grx_n] [get_bd_pins ${AurHierName}/qsfp_4x_grx_n]
connect_bd_net [get_bd_ports aur_qsfp_4x_grx_p] [get_bd_pins ${AurHierName}/qsfp_4x_grx_p]

connect_bd_net [get_bd_ports aur_qsfp_4x_gtx_n] [get_bd_pins ${AurHierName}/qsfp_4x_gtx_n]
connect_bd_net [get_bd_ports aur_qsfp_4x_gtx_p] [get_bd_pins ${AurHierName}/qsfp_4x_gtx_p]


connect_bd_net [get_bd_pins ${AurHierName}/s_axi_clk]            [get_bd_pins rst_ea_$AuroraClkNm/slowest_sync_clk]
connect_bd_net [get_bd_pins rst_ea_$AuroraClkNm/peripheral_aresetn] [get_bd_pins ${AurHierName}/s_axi_resetn]
# Make External avoids passing the signal width to this point. The bus is created automatically
make_bd_pins_external  [get_bd_pins ${AurHierName}/intc]
set_property name $Aurorairq [get_bd_ports intc_0]
# connect_bd_intf_net [get_bd_intf_ports $Auroraintf] [get_bd_intf_pins ${AurHierName}/s_axi]
set_property CONFIG.ASSOCIATED_BUSIF [get_property CONFIG.ASSOCIATED_BUSIF [get_bd_ports /$AuroraClkIf]]$Auroraintf: [get_bd_ports /$AuroraClkIf]

# Open an HBM Channels so the Ethernet DMA gets to the main memory
if { $AuroraMode == "dma" && ${AuroradmaMem} eq "hbm" } {
  set TxHBMCh [expr $AuroraHBMCh+0]
  set RxHBMCh [expr $AuroraHBMCh+1]
  set SgHBMCh [expr $AuroraHBMCh+2]

  set_property -dict [list CONFIG.USER_SAXI_${TxHBMCh} {TRUE}] [get_bd_cells hbm_0]
  set_property -dict [list CONFIG.USER_SAXI_${RxHBMCh} {TRUE}] [get_bd_cells hbm_0]
  set_property -dict [list CONFIG.USER_SAXI_${SgHBMCh} {TRUE}] [get_bd_cells hbm_0]

  connect_bd_intf_net [get_bd_intf_pins hbm_0/SAXI_${TxHBMCh}${HBM_AXI_LABEL}] [get_bd_intf_pins ${AurHierName}/m_axi_tx]
  connect_bd_intf_net [get_bd_intf_pins hbm_0/SAXI_${RxHBMCh}${HBM_AXI_LABEL}] [get_bd_intf_pins ${AurHierName}/m_axi_rx]
  connect_bd_intf_net [get_bd_intf_pins hbm_0/SAXI_${SgHBMCh}${HBM_AXI_LABEL}] [get_bd_intf_pins ${AurHierName}/m_axi_sg]

  connect_bd_net [get_bd_pins hbm_0/AXI_${TxHBMCh}_ACLK] [get_bd_pins ${AurHierName}/tx_clk]
  connect_bd_net [get_bd_pins hbm_0/AXI_${RxHBMCh}_ACLK] [get_bd_pins ${AurHierName}/rx_clk]
  connect_bd_net [get_bd_pins hbm_0/AXI_${SgHBMCh}_ACLK] [get_bd_pins ${AurHierName}/s_axi_clk]

  connect_bd_net [get_bd_pins hbm_0/AXI_${TxHBMCh}_ARESET_N] [get_bd_pins ${AurHierName}/tx_rstn]
  connect_bd_net [get_bd_pins hbm_0/AXI_${RxHBMCh}_ARESET_N] [get_bd_pins ${AurHierName}/rx_rstn]
  connect_bd_net [get_bd_pins hbm_0/AXI_${SgHBMCh}_ARESET_N] [get_bd_pins ${AurHierName}/s_axi_resetn]

} elseif { $AuroraMode == "raw" } {

    connect_bd_net [get_bd_pins aurora_${AurHierName}/SIMULATE_FRAME_CHECK] [get_bd_pins aurora_gnd/dout]
    connect_bd_net [get_bd_pins aurora_${AurHierName}/SIMULATE_FRAME_GEN]   [get_bd_pins aurora_gnd/dout]
    connect_bd_net [get_bd_pins aurora_${AurHierName}/DATA_INJ]             [get_bd_pins aurora_gnd/dout]

	make_bd_intf_pins_external  [get_bd_intf_pins aurora_${AurHierName}/S_USER_AXIS_UI_TX]
	make_bd_intf_pins_external  [get_bd_intf_pins aurora_${AurHierName}/M_USER_AXIS_UI_RX]
	
	# REQUIREMENT: The csv definition file can use only one intf name but
	# the ea wrapper module need to extend the name with _rx and _tx
	set_property name ${Auroraintf}_tx [get_bd_intf_ports S_USER_AXIS_UI_TX_0]
	set_property name ${Auroraintf}_rx [get_bd_intf_ports M_USER_AXIS_UI_RX_0]
	# TODO: RX and TX labels can create confussion: TX is injected to the core to be 
	# transmitted. RX is ouput from the core and served to the user logic
	
 	# set aurora_usr_clk $AuroraUsrClk	
	make_bd_pins_external  [get_bd_pins aurora_${AurHierName}/USER_CLK_OUT]
	# set_property name $AuroraUsrClk [get_bd_ports USER_CLK_OUT_0]
}

save_bd_design
