
# Timing constraints
#set_false_path -from [get_pins -hierarchical -filter {NAME=~*Ethernet*interrupt*/C}]


# QSFP28 Interfaces, QSFP_1, U55C
set_property -dict {LOC AA53 } [get_ports qsfp1_1x_grx_p] ; # MGTYRXP0_131 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC AA54 } [get_ports qsfp1_1x_grx_n] ; # MGTYRXN0_131 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC AA44 } [get_ports qsfp1_1x_gtx_p] ; # MGTYTXP0_131 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC AA45 } [get_ports qsfp1_1x_gtx_n] ; # MGTYTXN0_131 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10

set_property -dict {LOC AB42 } [get_ports qsfp1_ref_clk_p] ; # MGTREFCLK1P_131 from SI5394B
set_property -dict {LOC AB43 } [get_ports qsfp1_ref_clk_n] ;


# 161.1328125 MHz MGT reference clock (from SI5394B)
create_clock -period 6.206 -name qsfp1_refclk [get_ports qsfp1_ref_clk_p]

#set_false_path -from [get_pins -hierarchical -filter {NAME =~ interrupt*/C}]
# Following pin constraints are dummy. OE and FS signal outpus doesn't exist on U55C,
# but we create connections to unused pins to keep compatibility with u280

set_property -dict {LOC BN31 IOSTANDARD LVCMOS18} [get_ports qsfp1_oe_b]
set_property -dict {LOC BP31 IOSTANDARD LVCMOS18} [get_ports qsfp1_fs]

set_false_path -to [get_ports {qsfp1_oe_b qsfp1_fs}]
set_output_delay 0 [get_ports {qsfp1_oe_b qsfp1_fs}]
