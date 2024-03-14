## ================ JTAG ================

#--------------------------------------------
# Timing constraints for clock domains crossings (CDC), which didn't apply automatically (e.g. for GPIO)
set free_clk [get_clocks -of_objects [get_pins -hierarchical debug_hub/clk]]
set jtag_clk [get_clocks -of_objects [get_pins -hierarchical bscan_prim/m0_bscan_tck]]
# set_false_path -from $xxx_clk -to $yyy_clk
# controlling resync paths to be less than source clock period
# (-datapath_only to exclude clock paths)
set_max_delay -datapath_only -from $free_clk -to $jtag_clk [expr [get_property -min period $free_clk] * 0.9]
set_max_delay -datapath_only -from $jtag_clk -to $free_clk [expr [get_property -min period $jtag_clk] * 0.9]
## ================================
