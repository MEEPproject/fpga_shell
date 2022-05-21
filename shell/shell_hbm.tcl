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


#Make the configurations needed depending on the flexibility the Shell wants to provide.
# For instance, pick between targets:

if { "$g_board_part" eq "u55c" } {
	set HBM_AXI_LABEL "_8HI"
} else {
	set HBM_AXI_LABEL ""
}


putwarnings $HBMentry

set HBMClkNm  [dict get $HBMentry SyncClk Label]
set HBMFreq   [dict get $HBMentry SyncClk Freq]
set HBMname   [dict get $HBMentry SyncClk Name]
set HBMintf   [dict get $HBMentry IntfLabel]
set HBMReady  [dict get $HBMentry CalibDone]
set HBMChNum  [dict get $HBMentry EnChannel]

set HBMaddrWidth [dict get $HBMentry AxiAddrWidth]
set HBMdataWidth [dict get $HBMentry AxiDataWidth]
set HBMidWidth   [dict get $HBMentry AxiIdWidth]
set HBMuserWidth [dict get $HBMentry AxiUserWidth]
## CAUTION: Axi user signals are not supported as input to the protocol 
## converter to HBM. Hardcoded to 0
set HBMuserWidth 0

if { $HBMname == "PCIE_CLK"} {
	set HBMClockPin $pcie_clk_pin
        set HBMRstPin   $pcie_rst_pin
} else {
	set HBMClockPin [get_bd_pins rst_ea_$HBMClkNm/slowest_sync_clk]
	set HBMRstPin [get_bd_pins rst_ea_$HBMClkNm/peripheral_aresetn]
}

if { $APBClockPin == "" } {
	## APB candidate is an existing clock
	set APBClockPin [get_bd_pins rst_ea_$APBclkCandidate/slowest_sync_clk]
}

if { $APBRstPin == "" } {
        ## APB candidate is an existing clock
        set APBRstPin   [get_bd_pins rst_ea_$APBclkCandidate/peripheral_aresetn]
}


putmeeps "Creating HBM instance..."
### TODO: Support different user widths per AXI channel
### TODO: Region, prot and others can be extracted as the other widths
set hbm_axi4 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $HBMintf ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH $HBMaddrWidth \
   CONFIG.ARUSER_WIDTH $HBMuserWidth \
   CONFIG.AWUSER_WIDTH $HBMuserWidth \
   CONFIG.BUSER_WIDTH $HBMuserWidth \
   CONFIG.DATA_WIDTH $HBMdataWidth \
   CONFIG.FREQ_HZ $HBMFreq \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH $HBMidWidth \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH $HBMuserWidth \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH $HBMuserWidth \
   ] $hbm_axi4
   
## TODO: Make dependant of selected HBM channels number
if { $PCIeDMA != "yes" } {
	set PCIeHBM "false"
} else {
	set PCIeHBM "true"

}

# Create HBM instance if doesn't exsists already
if { [info exists hbm_inst] == 0 } {
  # Create instance: hbm_inst, and set properties
  set hbm_inst [ create_bd_cell -type ip -vlnv xilinx.com:ip:hbm:1.0 hbm_0 ]
  set_property -dict [ list \
   CONFIG.USER_APB_EN {false} \
   CONFIG.USER_CLK_SEL_LIST0 {AXI_00_ACLK} \
   CONFIG.USER_CLK_SEL_LIST1 {AXI_16_ACLK} \
   CONFIG.USER_HBM_CP_1 {6} \
   CONFIG.USER_HBM_DENSITY $HBMDensity \
   CONFIG.USER_HBM_FBDIV_1 {36} \
   CONFIG.USER_HBM_HEX_CP_RES_1 {0x0000A600} \
   CONFIG.USER_HBM_HEX_FBDIV_CLKOUTDIV_1 {0x00000902} \
   CONFIG.USER_HBM_HEX_LOCK_FB_REF_DLY_1 {0x00001f1f} \
   CONFIG.USER_HBM_LOCK_FB_DLY_1 {31} \
   CONFIG.USER_HBM_LOCK_REF_DLY_1 {31} \
   CONFIG.USER_HBM_RES_1 {10} \
   CONFIG.USER_HBM_STACK {2} \
   CONFIG.USER_MC_ENABLE_00 {TRUE} \
   CONFIG.USER_MC_ENABLE_01 {TRUE} \
   CONFIG.USER_MC_ENABLE_02 {TRUE} \
   CONFIG.USER_MC_ENABLE_03 {TRUE} \
   CONFIG.USER_MC_ENABLE_04 {TRUE} \
   CONFIG.USER_MC_ENABLE_05 {TRUE} \
   CONFIG.USER_MC_ENABLE_06 {TRUE} \
   CONFIG.USER_MC_ENABLE_07 {TRUE} \
   CONFIG.USER_MC_ENABLE_08 {TRUE} \
   CONFIG.USER_MC_ENABLE_09 {TRUE} \
   CONFIG.USER_MC_ENABLE_10 {TRUE} \
   CONFIG.USER_MC_ENABLE_11 {TRUE} \
   CONFIG.USER_MC_ENABLE_12 {TRUE} \
   CONFIG.USER_MC_ENABLE_13 {TRUE} \
   CONFIG.USER_MC_ENABLE_14 {TRUE} \
   CONFIG.USER_MC_ENABLE_15 {TRUE} \
   CONFIG.USER_MC_ENABLE_APB_01 {TRUE} \
   CONFIG.USER_PHY_ENABLE_08 {TRUE} \
   CONFIG.USER_PHY_ENABLE_09 {TRUE} \
   CONFIG.USER_PHY_ENABLE_10 {TRUE} \
   CONFIG.USER_PHY_ENABLE_11 {TRUE} \
   CONFIG.USER_PHY_ENABLE_12 {TRUE} \
   CONFIG.USER_PHY_ENABLE_13 {TRUE} \
   CONFIG.USER_PHY_ENABLE_14 {TRUE} \
   CONFIG.USER_PHY_ENABLE_15 {TRUE} \
   CONFIG.USER_SAXI_00 {true} \
   CONFIG.USER_SAXI_01 {false} \
   CONFIG.USER_SAXI_02 {false} \
   CONFIG.USER_SAXI_03 {false} \
   CONFIG.USER_SAXI_04 {false} \
   CONFIG.USER_SAXI_05 {false} \
   CONFIG.USER_SAXI_06 {false} \
   CONFIG.USER_SAXI_07 {false} \
   CONFIG.USER_SAXI_08 {false} \
   CONFIG.USER_SAXI_09 {false} \
   CONFIG.USER_SAXI_10 {false} \
   CONFIG.USER_SAXI_11 {false} \
   CONFIG.USER_SAXI_12 {false} \
   CONFIG.USER_SAXI_13 {false} \
   CONFIG.USER_SAXI_14 {false} \
   CONFIG.USER_SAXI_15 {false} \
   CONFIG.USER_SAXI_16 {false} \
   CONFIG.USER_SAXI_17 {false} \
   CONFIG.USER_SAXI_18 {false} \
   CONFIG.USER_SAXI_19 {false} \
   CONFIG.USER_SAXI_20 {false} \
   CONFIG.USER_SAXI_21 {false} \
   CONFIG.USER_SAXI_22 {false} \
   CONFIG.USER_SAXI_23 {false} \
   CONFIG.USER_SAXI_24 {false} \
   CONFIG.USER_SAXI_25 {false} \
   CONFIG.USER_SAXI_26 {false} \
   CONFIG.USER_SAXI_27 {false} \
   CONFIG.USER_SAXI_28 {false} \
   CONFIG.USER_SAXI_29 {false} \
   CONFIG.USER_SAXI_30 {false} \
   CONFIG.USER_SAXI_31 $PCIeHBM \
   CONFIG.USER_SWITCH_ENABLE_01 {TRUE} \
 ] $hbm_inst
	

## APB CLOCKS and RESET
	
	if { $APBclk eq "" } {
	
	} else {
	
	}
	
	create_bd_cell -type ip -vlnv $meep_util_ds_buf util_ds_buf_hbm_clk
	make_bd_intf_pins_external  [get_bd_intf_pins util_ds_buf_hbm_clk/CLK_IN_D]
	set_property name sysclk0 [get_bd_intf_ports CLK_IN_D_0]
	connect_bd_net [get_bd_pins util_ds_buf_hbm_clk/IBUF_OUT] [get_bd_pins hbm_0/HBM_REF_CLK_0]
	connect_bd_net [get_bd_pins util_ds_buf_hbm_clk/IBUF_OUT] [get_bd_pins hbm_0/HBM_REF_CLK_1]
	### TODO: APB CLOCK Can't be the same as ACLK. Needs to be a different source
	connect_bd_net [get_bd_pins hbm_0/APB_0_PCLK] $APBClockPin
	connect_bd_net [get_bd_pins hbm_0/APB_1_PCLK] $APBClockPin
	set hbm_cattrip [ create_bd_port -dir O -from 0 -to 0 hbm_cattrip ]
	## One CATTRIP per stack, OR it
	create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 hbm_cattrip_or
	set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {or} CONFIG.LOGO_FILE {data/sym_orgate.png}] [get_bd_cells hbm_cattrip_or]
	connect_bd_net [get_bd_pins hbm_0/DRAM_0_STAT_CATTRIP] [get_bd_pins hbm_cattrip_or/Op1]
	connect_bd_net [get_bd_pins hbm_0/DRAM_1_STAT_CATTRIP] [get_bd_pins hbm_cattrip_or/Op2]
	connect_bd_net [get_bd_ports hbm_cattrip] [get_bd_pins hbm_cattrip_or/Res]
	
	if { $HBMReady != ""} {
        	create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 APB_rst_or
	    set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {and} CONFIG.LOGO_FILE {data/sym_andgate.png}] [get_bd_cells APB_rst_or]
	    connect_bd_net [get_bd_pins hbm_0/apb_complete_0] [get_bd_pins APB_rst_or/Op1]
	    connect_bd_net [get_bd_pins hbm_0/apb_complete_1] [get_bd_pins APB_rst_or/Op2]
        make_bd_pins_external  [get_bd_pins APB_rst_or/Res]
        set_property name $HBMReady [get_bd_ports Res_0]
	}

	connect_bd_net [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_ea_$HBMClkNm/dcm_locked]

	#foreach Number of APB interfaces, one per stack
	connect_bd_net [get_bd_pins hbm_0/APB_0_PRESET_N] $APBRstPin
	connect_bd_net [get_bd_pins hbm_0/APB_1_PRESET_N] $APBRstPin

}

###################################################################
## Use protocol and data width converters blocks to translate 
## HBM-User Inft protocols -HBM is AXI3-
## Not convert if user interface is already 256 bits
###################################################################
# TODO: HBM AXI Labels must be variables generated during the shell definition
# TODO: All the blocks than shape the HBM pipe need to be labeled depending on the channel numbering
# NEED TO ENABLE THE RIGHT HBM CHANNEL!!
	set_property -dict [list CONFIG.USER_CLK_SEL_LIST0 AXI_${HBMChNum}_ACLK CONFIG.USER_SAXI_${HBMChNum} {true}] [get_bd_cells hbm_0]

	## Width
	if { $HBMdataWidth != 256 } {
		create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_convert_${HBMChNum}
	    connect_bd_intf_net [get_bd_intf_ports $HBMintf] [get_bd_intf_pins axi_protocol_convert_${HBMChNum}/S_AXI]
        connect_bd_net [get_bd_pins axi_protocol_convert_${HBMChNum}/aclk] $HBMClockPin
		# The protocol converter is not needed if the RAMA IP is used.
		# TODO: RAMA might be not the best option for non-random accesss. 
		create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dwidth_converter:2.1 axi_dwidth_converter_${HBMChNum}
		connect_bd_net [get_bd_pins axi_dwidth_converter_${HBMChNum}/s_axi_aclk] $HBMClockPin
		connect_bd_intf_net [get_bd_intf_pins axi_protocol_convert_${HBMChNum}/M_AXI] [get_bd_intf_pins axi_dwidth_converter_${HBMChNum}/S_AXI]
		connect_bd_intf_net [get_bd_intf_pins axi_dwidth_converter_${HBMChNum}/M_AXI] [get_bd_intf_pins hbm_0/SAXI_${HBMChNum}${HBM_AXI_LABEL}]
		connect_bd_net $HBMRstPin [get_bd_pins axi_protocol_convert_${HBMChNum}/aresetn]
		connect_bd_net $HBMRstPin [get_bd_pins axi_dwidth_converter_${HBMChNum}/s_axi_aresetn] 

	} else {
		create_bd_cell -type ip -vlnv xilinx.com:ip:rama:1.1 rama_${HBMChNum}
		connect_bd_intf_net [get_bd_intf_pins rama_${HBMChNum}/m_axi] [get_bd_intf_pins hbm_0/SAXI_${HBMChNum}${HBM_AXI_LABEL}]
		connect_bd_intf_net [get_bd_intf_ports $HBMintf] [get_bd_intf_pins rama_${HBMChNum}/s_axi]
	        connect_bd_net [get_bd_pins rama_${HBMChNum}/axi_aclk] $HBMClockPin
		connect_bd_net $HBMRstPin [get_bd_pins rama_${HBMChNum}/axi_aresetn]
		# RAMA explicitly forbids this signals
		set_property CONFIG.HAS_CACHE  0 [get_bd_intf_ports $HBMintf]
                set_property CONFIG.HAS_LOCK   0 [get_bd_intf_ports $HBMintf]
                set_property CONFIG.HAS_QOS    0 [get_bd_intf_ports $HBMintf]
                set_property CONFIG.HAS_REGION 0 [get_bd_intf_ports $HBMintf]
                set_property CONFIG.HAS_PROT   0 [get_bd_intf_ports $HBMintf]		

	}

	## IF PCIe has a direct access to the main memory, open an HBM channel for it
	## PCIeDMAdone is set on shell_qdma.tcl
	save_bd_design
	if { $PCIeDMA eq "dma" && $PCIeDMAdone == 0} {

		# Between 16 and 31, SEL_LIST1 instead of SEL_LIST0
		set_property -dict [list CONFIG.USER_CLK_SEL_LIST1 {AXI_31_ACLK} CONFIG.USER_SAXI_31 {true}] [get_bd_cells hbm_0]

		create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_convert_31
		create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dwidth_converter:2.1 axi_dwidth_converter_31
		create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_register_slice_31
		connect_bd_intf_net [get_bd_intf_pins axi_protocol_convert_31/M_AXI] [get_bd_intf_pins axi_dwidth_converter_31/S_AXI]
		connect_bd_intf_net [get_bd_intf_pins qdma_0/M_AXI] [get_bd_intf_pins axi_protocol_convert_31/S_AXI]
		connect_bd_net [get_bd_pins qdma_0/axi_aclk] [get_bd_pins hbm_0/AXI_31_ACLK]
		connect_bd_net [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins hbm_0/AXI_31_ARESET_N]
		connect_bd_net [get_bd_pins axi_dwidth_converter_31/s_axi_aresetn] [get_bd_pins qdma_0/axi_aresetn]
		connect_bd_net [get_bd_pins axi_protocol_convert_31/aresetn] [get_bd_pins qdma_0/axi_aresetn]
		connect_bd_net [get_bd_pins axi_dwidth_converter_31/s_axi_aclk] [get_bd_pins qdma_0/axi_aclk]
		connect_bd_net [get_bd_pins axi_protocol_convert_31/aclk] [get_bd_pins qdma_0/axi_aclk]
		connect_bd_intf_net [get_bd_intf_pins axi_dwidth_converter_31/M_AXI] [get_bd_intf_pins axi_register_slice_31/S_AXI]
		connect_bd_intf_net [get_bd_intf_pins axi_register_slice_31/M_AXI] [get_bd_intf_pins hbm_0/SAXI_31${HBM_AXI_LABEL}]
		connect_bd_net [get_bd_pins axi_register_slice_31/aclk] [get_bd_pins qdma_0/axi_aclk]
		connect_bd_net [get_bd_pins axi_register_slice_31/aresetn] [get_bd_pins qdma_0/axi_aresetn]
		set_property -dict [list CONFIG.USE_AUTOPIPELINING {1}] [get_bd_cells axi_register_slice_31]	
		set PCIeDMAdone 1
	}

#Connect Clocks	
connect_bd_net [get_bd_pins hbm_0/AXI_${HBMChNum}_ACLK] $HBMClockPin


########### RESET CONNECTIONS ################

## Connect Reset Block clk

## TODO: Handle processor system reset
### Create a list of connections belonging to a interface

### HBM Interface, list of resets connections
#foreach Number of HBM Channels
connect_bd_net $HBMRstPin [get_bd_pins hbm_0/AXI_${HBMChNum}_ARESET_N]

save_bd_design
