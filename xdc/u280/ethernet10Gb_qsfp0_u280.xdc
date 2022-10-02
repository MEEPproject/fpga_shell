# QSFP28 Interfaces

set_property -dict {LOC L53 } [get_ports qsfp0_1x_grx_p] ; # MGTYRXP0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L54 } [get_ports qsfp0_1x_grx_n] ; # MGTYRXN0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L48 } [get_ports qsfp0_1x_gtx_p] ; # MGTYTXP0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L49 } [get_ports qsfp0_1x_gtx_n] ; # MGTYTXN0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10

set_property -dict {LOC R40 } [get_ports qsfp0_ref_clk_p] ; # MGTREFCLK1P_134 from SI546
set_property -dict {LOC R41 } [get_ports qsfp0_ref_clk_n] ; # MGTREFCLK1N_134 from SI546

set_property -dict {LOC H32 IOSTANDARD LVCMOS18} [get_ports qsfp0_oe_b]
set_property -dict {LOC G32 IOSTANDARD LVCMOS18} [get_ports qsfp0_fs]

# 156.25 MHz MGT reference clock (from SI570)
#create_clock -period 6.400 -name qsfp0_mgt_refclk_0 [get_ports qsfp0_mgt_refclk_0_p]

# 156.25 MHz MGT reference clock (from SI546, fs = 0)
#create_clock -period 6.400 -name qsfp0_mgt_refclk_1 [get_ports qsfp0_mgt_refclk_1_p]

# 161.1328125 MHz MGT reference clock (from SI546, fs = 1)
create_clock -period 6.206 -name qsfp0_refclk [get_ports qsfp0_ref_clk_p]

set_false_path -to [get_ports {qsfp0_oe_b qsfp0_fs}]
set_output_delay 0 [get_ports {qsfp0_oe_b qsfp0_fs}]

#set_false_path -from [get_pins -hierarchical -filter {NAME =~ interrupt*/C}]

#set_max_delay -from [get_pins meep_shell_inst/Ethernet10Gb_qsfp0/axi_dma_0/U0/I_AXI_DMA_REG_MODULE/GEN_MM2S_REGISTERS.GEN_INTROUT_ASYNC.PROC_REG_INTR2LITE/GENERATE_LEVEL_P_S_CDC.SINGLE_BIT.CROSS_PLEVEL_IN2SCNDRY_s_level_out_d4/C]  3.0
#set_max_delay -from [get_pins meep_shell_inst/Ethernet10Gb_qsfp0/axi_dma_0/U0/I_AXI_DMA_REG_MODULE/GEN_MM2S_REGISTERS.GEN_INTROUT_ASYNC.PROC_REG_INTR2LITE/GENERATE_LEVEL_P_S_CDC.SINGLE_BIT.CROSS_PLEVEL_IN2SCNDRY_s_level_out_d4/C]  3.0
