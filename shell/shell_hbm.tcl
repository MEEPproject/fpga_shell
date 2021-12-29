#Make the configurations needed depending on the flexibility the Shell wants to provide.
# For instance, pick between targets:

if { "$g_board_part" eq "u55c" } {
	set HBM_AXI_LABEL "_8HI"
} else {
	set HBM_AXI_LABEL ""
}

# set_property -dict [list CONFIG.USER_HBM_DENSITY {8GB} \
# CONFIG.USER_HBM_STACK {2} CONFIG.USER_MEMORY_DISPLAY {8192} \
# CONFIG.USER_SWITCH_ENABLE_01 {TRUE} CONFIG.USER_HBM_CP_1 {6} \
# CONFIG.USER_HBM_RES_1 {10} CONFIG.USER_HBM_LOCK_REF_DLY_1 {31} \
# CONFIG.USER_HBM_LOCK_FB_DLY_1 {31} CONFIG.USER_HBM_FBDIV_1 {36} \
# CONFIG.USER_HBM_HEX_CP_RES_1 {0x0000A600} \
# CONFIG.USER_HBM_HEX_LOCK_FB_REF_DLY_1 {0x00001f1f} \
# CONFIG.USER_HBM_HEX_FBDIV_CLKOUTDIV_1 {0x00000902} CONFIG.USER_CLK_SEL_LIST0 {AXI_01_ACLK} CONFIG.USER_CLK_SEL_LIST1 {AXI_23_ACLK} CONFIG.USER_MC_ENABLE_08 {TRUE} CONFIG.USER_MC_ENABLE_09 {TRUE} CONFIG.USER_MC_ENABLE_10 {TRUE} CONFIG.USER_MC_ENABLE_11 {TRUE} CONFIG.USER_MC_ENABLE_12 {TRUE} CONFIG.USER_MC_ENABLE_13 {TRUE} CONFIG.USER_MC_ENABLE_14 {TRUE} CONFIG.USER_MC_ENABLE_15 {TRUE} CONFIG.USER_MC_ENABLE_APB_01 {TRUE} CONFIG.USER_SAXI_00 {false} CONFIG.USER_SAXI_15 {true} CONFIG.USER_PHY_ENABLE_08 {TRUE} CONFIG.USER_PHY_ENABLE_09 {TRUE} CONFIG.USER_PHY_ENABLE_10 {TRUE} CONFIG.USER_PHY_ENABLE_11 {TRUE} CONFIG.USER_PHY_ENABLE_12 {TRUE} CONFIG.USER_PHY_ENABLE_13 {TRUE} CONFIG.USER_PHY_ENABLE_14 {TRUE} CONFIG.USER_PHY_ENABLE_15 {TRUE}] [get_bd_cells hbm_0]


# source tcl/procedures.tcl
# source tcl/shell_env.tcl

# foreach dicEntry $ShellEnabledIntf {

	# set IntfName [dict get $dicEntry Name]
	
	# if {[regexp -inline -all "HBM" $IntfName] ne "" } {
		# set HBMentry $dicEntry
	# }
	
# }

putwarnings $HBMentry

set HBMClkNm [dict get $HBMentry SyncClk Label]
set HBMFreq  [dict get $HBMentry SyncClk Freq]
set HBMname  [dict get $HBMentry SyncClk Name]
set HBMintf  [dict get $HBMentry IntfLabel]
set HBMReady [dict get $HBMentry CalibDone]

set HBMaddrWidth [dict get $HBMentry AxiAddrWidth]
set HBMdataWidth [dict get $HBMentry AxiDataWidth]
set HBMidWidth   [dict get $HBMentry AxiIdWidth]
set HBMuserWidth [dict get $HBMentry AxiUserWidth]
## CAUTION: Axi user signals are not supported as input to the protocol 
## converter to HBM. Hardcoded to 0
set HBMuserWidth 0

#[get_bd_pins rst_ea_$HBMClkNm/slowest_sync_clk]
set HBMClockPin [get_bd_pins rst_ea_$HBMClkNm/slowest_sync_clk]
set APBClockPin [get_bd_pins rst_ea_$APBclk/slowest_sync_clk]


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
  # Create instance: hbm_0, and set properties
  set hbm_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:hbm:1.0 hbm_0 ]
  set_property -dict [ list \
   CONFIG.USER_APB_EN {false} \
   CONFIG.USER_CLK_SEL_LIST0 {AXI_00_ACLK} \
   CONFIG.USER_CLK_SEL_LIST1 {AXI_16_ACLK} \
   CONFIG.USER_HBM_CP_1 {6} \
   CONFIG.USER_HBM_DENSITY {8GB} \
   CONFIG.USER_HBM_FBDIV_1 {36} \
   CONFIG.USER_HBM_HEX_CP_RES_1 {0x0000A600} \
   CONFIG.USER_HBM_HEX_FBDIV_CLKOUTDIV_1 {0x00000902} \
   CONFIG.USER_HBM_HEX_LOCK_FB_REF_DLY_1 {0x00001f1f} \
   CONFIG.USER_HBM_LOCK_FB_DLY_1 {31} \
   CONFIG.USER_HBM_LOCK_REF_DLY_1 {31} \
   CONFIG.USER_HBM_RES_1 {10} \
   CONFIG.USER_HBM_STACK {2} \
   CONFIG.USER_MC_ENABLE_08 {TRUE} \
   CONFIG.USER_MC_ENABLE_09 {TRUE} \
   CONFIG.USER_MC_ENABLE_10 {TRUE} \
   CONFIG.USER_MC_ENABLE_11 {TRUE} \
   CONFIG.USER_MC_ENABLE_12 {TRUE} \
   CONFIG.USER_MC_ENABLE_13 {TRUE} \
   CONFIG.USER_MC_ENABLE_14 {TRUE} \
   CONFIG.USER_MC_ENABLE_15 {TRUE} \
   CONFIG.USER_MC_ENABLE_APB_01 {TRUE} \
   CONFIG.USER_MEMORY_DISPLAY {8192} \
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
   CONFIG.USER_SAXI_08 {true} \
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
   CONFIG.USER_SAXI_31 {false} \
   CONFIG.USER_SWITCH_ENABLE_01 {TRUE} \
 ] $hbm_0
	
	
	## APB CLOCKS and RESET
	
	if { $APBclk eq "" } {
	
	} else {
	
	}
	
	create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0
	make_bd_intf_pins_external  [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]
	set_property name sysclk0 [get_bd_intf_ports CLK_IN_D_0]
	connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins hbm_0/HBM_REF_CLK_0]
	connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins hbm_0/HBM_REF_CLK_1]
	### TODO: APB CLOCK Can't be the same as ACLK. Needs to be a different source
	connect_bd_net [get_bd_pins hbm_0/AXI_08_ACLK] $HBMClockPin
	connect_bd_net [get_bd_pins hbm_0/APB_0_PCLK] $APBClockPin
    connect_bd_net [get_bd_pins hbm_0/APB_1_PCLK] $APBClockPin
	set hbm_cattrip [ create_bd_port -dir O -from 0 -to 0 hbm_cattrip ]
	## One CATTRIP per stack, OR it
	create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_2
	set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {or} CONFIG.LOGO_FILE {data/sym_orgate.png}] [get_bd_cells util_vector_logic_2]
	connect_bd_net [get_bd_pins hbm_0/DRAM_0_STAT_CATTRIP] [get_bd_pins util_vector_logic_2/Op1]
	connect_bd_net [get_bd_pins hbm_0/DRAM_1_STAT_CATTRIP] [get_bd_pins util_vector_logic_2/Op2]
	connect_bd_net [get_bd_ports hbm_cattrip] [get_bd_pins util_vector_logic_2/Res]


###################################################################
## Use protocol and data width converters blocks to translate 
## HBM-User Inft protocols -HBM is AXI3-
## Not convert if user interface is already 256 bits
###################################################################

	create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_convert_0
	connect_bd_intf_net [get_bd_intf_ports $HBMintf] [get_bd_intf_pins axi_protocol_convert_0/S_AXI]
	connect_bd_net [get_bd_pins axi_protocol_convert_0/aclk] $HBMClockPin
	
	## Width
	if { $HBMdataWidth != 256 } {
		create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dwidth_converter:2.1 axi_dwidth_converter_0
		connect_bd_net [get_bd_pins axi_dwidth_converter_0/s_axi_aclk] $HBMClockPin
		#connect_bd_net [get_bd_pins rst_ea_domain/peripheral_aresetn] [get_bd_pins axi_dwidth_converter_0/s_axi_aresetn]
		connect_bd_intf_net [get_bd_intf_pins axi_protocol_convert_0/M_AXI] [get_bd_intf_pins axi_dwidth_converter_0/S_AXI]
		connect_bd_intf_net [get_bd_intf_pins axi_dwidth_converter_0/M_AXI] [get_bd_intf_pins hbm_0/SAXI_08]
	} else {
		connect_bd_intf_net [get_bd_intf_pins axi_protocol_convert_0/M_AXI] [get_bd_intf_pins hbm_0/SAXI_08]
	}

	## IF PCIe has a direct access to the main memory, open an HBM channel for it
	## Actually, we are using an AXI interconnect, not optimal
	if { $PCIeDMA eq "yes"} {

		set_property -dict [list CONFIG.USER_CLK_SEL_LIST0 {AXI_00_ACLK} CONFIG.USER_SAXI_00 {true}] [get_bd_cells hbm_0]
		create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_convert_1
		create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dwidth_converter:2.1 axi_dwidth_converter_1
		create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_register_slice_0
		connect_bd_intf_net [get_bd_intf_pins axi_protocol_convert_1/M_AXI] [get_bd_intf_pins axi_dwidth_converter_1/S_AXI]
		connect_bd_intf_net [get_bd_intf_pins qdma_0/M_AXI] [get_bd_intf_pins axi_protocol_convert_1/S_AXI]
		connect_bd_net [get_bd_pins qdma_0/axi_aclk] [get_bd_pins hbm_0/AXI_00_ACLK]
		connect_bd_net [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins hbm_0/AXI_00_ARESET_N]
		connect_bd_net [get_bd_pins axi_dwidth_converter_1/s_axi_aresetn] [get_bd_pins qdma_0/axi_aresetn]
		connect_bd_net [get_bd_pins axi_protocol_convert_1/aresetn] [get_bd_pins qdma_0/axi_aresetn]
		connect_bd_net [get_bd_pins axi_dwidth_converter_1/s_axi_aclk] [get_bd_pins qdma_0/axi_aclk]
		connect_bd_net [get_bd_pins axi_protocol_convert_1/aclk] [get_bd_pins qdma_0/axi_aclk]
		connect_bd_intf_net [get_bd_intf_pins axi_dwidth_converter_1/M_AXI] [get_bd_intf_pins axi_register_slice_0/S_AXI]
		connect_bd_intf_net [get_bd_intf_pins axi_register_slice_0/M_AXI] [get_bd_intf_pins hbm_0/SAXI_00]
		connect_bd_net [get_bd_pins axi_register_slice_0/aclk] [get_bd_pins qdma_0/axi_aclk]
		connect_bd_net [get_bd_pins axi_register_slice_0/aresetn] [get_bd_pins qdma_0/axi_aresetn]
		set_property -dict [list CONFIG.USE_AUTOPIPELINING {1}] [get_bd_cells axi_register_slice_0]		
	}


## HBM Calibration Complete, 
## It can be used when it has been defined in the definition file

if { $HBMReady != ""} {
	create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0
        set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {and} CONFIG.LOGO_FILE {data/sym_andgate.png}] [get_bd_cells util_vector_logic_0]
        connect_bd_net [get_bd_pins hbm_0/apb_complete_0] [get_bd_pins util_vector_logic_0/Op1]
        connect_bd_net [get_bd_pins hbm_0/apb_complete_1] [get_bd_pins util_vector_logic_0/Op2]
	make_bd_pins_external  [get_bd_pins util_vector_logic_0/Res]
	set_property name $HBMReady [get_bd_ports Res_0]
}

########### RESET CONNECTIONS ################

## Connect Reset Block clk

## TODO: Handle processor system reset
### Create a list of connections belonging to a interface

### HBM Interface, list of resets connections
#foreach Number of HBM Channels
connect_bd_net [get_bd_pins rst_ea_$HBMClkNm/peripheral_aresetn] [get_bd_pins hbm_0/AXI_08_ARESET_N]
connect_bd_net [get_bd_pins rst_ea_$HBMClkNm/peripheral_aresetn] [get_bd_pins axi_protocol_convert_0/aresetn]
connect_bd_net [get_bd_pins rst_ea_$HBMClkNm/peripheral_aresetn] [get_bd_pins axi_dwidth_converter_0/s_axi_aresetn]
connect_bd_net [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_ea_$HBMClkNm/dcm_locked]

#foreach Number of APB interfaces, one per stack
connect_bd_net [get_bd_pins hbm_0/APB_0_PRESET_N] [get_bd_pins rst_ea_$HBMClkNm/peripheral_aresetn]
connect_bd_net [get_bd_pins hbm_0/APB_1_PRESET_N] [get_bd_pins rst_ea_$HBMClkNm/peripheral_aresetn]

save_bd_design
