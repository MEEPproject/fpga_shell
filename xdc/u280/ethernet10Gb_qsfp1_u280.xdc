# QSFP28 Interfaces

set_property -dict {LOC G53 } [get_ports qsfp1_1x_grx_p] ; # MGTYRXP0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC G54 } [get_ports qsfp1_1x_grx_n] ; # MGTYRXN0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC G48 } [get_ports qsfp1_1x_gtx_p] ; # MGTYTXP0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC G49 } [get_ports qsfp1_1x_gtx_n] ; # MGTYTXN0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11

set_property -dict {LOC M42 } [get_ports qsfp1_ref_clk_p] ; # MGTREFCLK1P_135 from SI546
set_property -dict {LOC M43 } [get_ports qsfp1_ref_clk_n] ; # MGTREFCLK1N_135 from SI546

set_property -dict {LOC H30 IOSTANDARD LVCMOS18} [get_ports qsfp1_oe_b]
set_property -dict {LOC G33 IOSTANDARD LVCMOS18} [get_ports qsfp1_fs]

# 156.25 MHz MGT reference clock (from SI546, fs = 0)
#create_clock -period 6.400 -name qsfp0_mgt_refclk_1 [get_ports qsfp0_mgt_refclk_1_p]

# 161.1328125 MHz MGT reference clock (from SI546, fs = 1)



create_clock -period 6.206 -name qsfp1_refclk [get_ports qsfp1_ref_clk_p]


set_false_path -to [get_ports {qsfp1_oe_b qsfp1_fs}]
set_output_delay 0 [get_ports {qsfp1_oe_b qsfp1_fs}]


#set_max_delay -from [get_pins meep_shell_inst/Ethernet10Gb_qsfp1/axi_dma_0/U0/I_AXI_DMA_REG_MODULE/GEN_MM2S_REGISTERS.GEN_INTROUT_ASYNC.PROC_REG_INTR2LITE/GENERATE_LEVEL_P_S_CDC.SINGLE_BIT.CROSS_PLEVEL_IN2SCNDRY_s_level_out_d4/C]  3.0
#set_max_delay -from [get_pins meep_shell_inst/Ethernet10Gb_qsfp1/axi_dma_0/U0/I_AXI_DMA_REG_MODULE/GEN_S2MM_REGISTERS.GEN_INTROUT_ASYNC.PROC_REG_INTR2LITE/GENERATE_LEVEL_P_S_CDC.SINGLE_BIT.CROSS_PLEVEL_IN2SCNDRY_s_level_out_d4/C]  3.0