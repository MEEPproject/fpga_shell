# Be careful, u280 is using QSFP0, and this looks like QSFP1

set_property PACKAGE_PIN AB43               [get_ports qsfp_ref_clk_n] ;# Bank 135 - MGTREFCLK1N_135
set_property PACKAGE_PIN AB42               [get_ports qsfp_ref_clk_p] ;# Bank 135 - MGTREFCLK1P_135
create_clock -period 6.206 -name QSFP1X_CLK [get_ports qsfp_ref_clk_p]

