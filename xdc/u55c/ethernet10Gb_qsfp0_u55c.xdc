
# Timing constraints
#set_false_path -from [get_pins -hierarchical -filter {NAME=~*Ethernet*interrupt*/C}]


# QSFP28 Interfaces, QSFP_0, U55C
set_property -dict {LOC AD51 } [get_ports qsfp0_1x_grx_p] ; # MGTYRXP0_130 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC AD52 } [get_ports qsfp0_1x_grx_n] ; # MGTYRXN0_130 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC AD46 } [get_ports qsfp0_1x_gtx_p] ; # MGTYTXP0_130 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC AD47 } [get_ports qsfp0_1x_gtx_n] ; # MGTYTXN0_130 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10

set_property -dict {LOC AD42 } [get_ports qsfp0_ref_clk_p] ; # MGTREFCLK1P_130 from SI5394B
set_property -dict {LOC AD43 } [get_ports qsfp0_ref_clk_n] ; 


# 161.1328125 MHz MGT reference clock (from SI5394B)
create_clock -period 6.206 -name qsfp0_refclk [get_ports qsfp0_ref_clk_p]

#set_false_path -from [get_pins -hierarchical -filter {NAME =~ interrupt*/C}]
# Following pin constraints are dummy. OE and FS signal outpus doesn't exist on U55C,
# but we create connections to unused pins to keep compatibility with u280

set_property -dict {LOC BL30 IOSTANDARD LVCMOS18} [get_ports qsfp0_oe_b]
set_property -dict {LOC BN30 IOSTANDARD LVCMOS18} [get_ports qsfp0_fs]

set_false_path -to [get_ports {qsfp0_oe_b qsfp0_fs}]
set_output_delay 0 [get_ports {qsfp0_oe_b qsfp0_fs}]


set_false_path -from [get_pins meep_shell_inst/Ethernet10Gb_qsfp0/axi_dma_0/U0/I_AXI_DMA_REG_MODULE/GEN_S2MM_REGISTERS.GEN_INTROUT_ASYNC.PROC_REG_INTR2LITE/GENERATE_LEVEL_P_S_CDC.SINGLE_BIT.CROSS_PLEVEL_IN2SCNDRY_s_level_out_d4/C]
set_false_path -from [get_pins meep_shell_inst/Ethernet10Gb_qsfp0/axi_dma_0/U0/I_AXI_DMA_REG_MODULE/GEN_MM2S_REGISTERS.GEN_INTROUT_ASYNC.PROC_REG_INTR2LITE/GENERATE_LEVEL_P_S_CDC.SINGLE_BIT.CROSS_PLEVEL_IN2SCNDRY_s_level_out_d4/C] 
 