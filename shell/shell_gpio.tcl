
set NumGPIO   [dict get $g_gpio Width]
set IntfName  [dict get $g_gpio IntfLabel]
set InitValue [dict get $g_gpio InitValue]


create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property -dict [list CONFIG.C_GPIO_WIDTH "$NumGPIO" CONFIG.C_ALL_OUTPUTS "$NumGPIO"] [get_bd_cells axi_gpio_0]
connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins clk_wiz_1/clk_out1]
connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins rst_ea_domain/peripheral_aresetn]
make_bd_pins_external  [get_bd_pins axi_gpio_0/gpio_io_o]
set_property name $IntfName [get_bd_ports gpio_io_o_0]
set_property -dict [list CONFIG.C_DOUT_DEFAULT $InitValue] [get_bd_cells axi_gpio_0]


save_bd_design