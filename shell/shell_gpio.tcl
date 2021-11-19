
if { [info exists DDR4entry] } {
	set master_gpio M01
	set_property -dict [list CONFIG.NUM_MI {2}] [get_bd_cells axi_interconnect_1]
	connect_bd_net [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins clk_wiz_1/clk_out1]
	connect_bd_net [get_bd_pins axi_interconnect_1/M01_ARESETN] [get_bd_pins rst_ea_domain/peripheral_aresetn]

} elseif { [info exists HBMentry] } {
	set master_gpio M00
}

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property -dict [list CONFIG.C_GPIO_WIDTH {1} CONFIG.C_ALL_OUTPUTS {1}] [get_bd_cells axi_gpio_0]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_1/${master_gpio}_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins clk_wiz_1/clk_out1]
connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins rst_ea_domain/peripheral_aresetn]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
set_property name gpio_concat_0 [get_bd_cells xlconcat_0]
set_property -dict [list CONFIG.NUM_PORTS {1}] [get_bd_cells gpio_concat_0]
connect_bd_net [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins gpio_concat_0/In0]
make_bd_pins_external  [get_bd_pins gpio_concat_0/dout]
set_property name rstn_asic [get_bd_ports dout_0]