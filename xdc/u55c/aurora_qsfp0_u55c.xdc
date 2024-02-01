## ================ Ethernet ================
## Commented pin locations are applied automatically due to configurations inside Ethernet CMAC core (made in BD)
#--------------------------------------------
## Input Clocks and Controls for QSFP28 Port 0
##
##    1) Si5394J - SiLabs Si5394B-A11828-GMR Programmable Oscillator (Re-programming I2C access via I2C_SI5394)
##    						   |
##     						   |-> OUT0  SYNCE_CLK0_P/SYNCE_CLK0_N 161.1328125 MHz - onboard QSFP Clock
##                             |   PINS: MGTREFCLK0P_130_AD42/MGTREFCLK0N_130_AD43

#create_clock is not needed in case of connecting QSFP clock to 100Gb CMAC, but needed for Aurora and 1Gb PHY (gig_ethernet_pcs_pma)
set_property PACKAGE_PIN AD43 [get_ports "qsfp0_ref_clk_n"] ;# Bank 130 - MGTREFCLK0N_130
set_property PACKAGE_PIN AD42 [get_ports "qsfp0_ref_clk_p"] ;# Bank 130 - MGTREFCLK0P_130
create_clock -period 6.206 -name QSFP0_CLK [get_ports "qsfp0_ref_clk_p"]

#--------------------------------------------
# Specifying the placement of QSFP clock domain modules into single SLR to facilitate routing
# https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_1/ug912-vivado-properties.pdf#page=386
#Collecting all units from correspondingly Tx and Rx domains,
#excluding AXI register slices intended to facilitate SLR crossing on the way to/from HBM located in SLR0
set aur_clk_units [get_cells -filter {NAME !~ *axi_reg_slice_tx && NAME !~ *txrx_rst_gen} -of_objects [get_nets -of_objects [get_pins -hierarchical aurora_64b66b_0/user_clk_out]]]
#Since clocks are not applied to memories explicitly in BD, include them explicitly to SLR placement.
set eth_txmem [get_cells -hierarchical eth_tx_mem]
set eth_rxmem [get_cells -hierarchical eth_rx_mem]
#Setting specific SLR to which QSFP are wired since placer may miss it if just "group_name" is applied
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells "$aur_clk_units $eth_txmem $eth_rxmem"]

#--------------------------------------------
# Timing constraints for clock domains crossings (CDC), which didn't apply automatically (e.g. for GPIO)
set sys_clk [get_clocks -of_objects [get_pins -hierarchical AuroraSyst_*/s_axi_clk]]
set tx_clk  [get_clocks -of_objects [get_pins -hierarchical aurora_64b66b_0/user_clk_out ]]
# set_false_path -from $xxx_clk -to $yyy_clk
# controlling resync paths to be less than source clock period
# (-datapath_only to exclude clock paths)
set_max_delay -datapath_only -from $sys_clk -to $tx_clk  [expr [get_property -min period $sys_clk] * 0.9]
set_max_delay -datapath_only -from $tx_clk  -to $sys_clk [expr [get_property -min period $tx_clk ] * 0.9]
## ================================
