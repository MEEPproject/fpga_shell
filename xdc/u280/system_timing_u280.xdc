create_clock -period 10.000 -name SYSCLK_0      [get_ports sysclk0_clk_p]
create_clock -period 10.000 -name SYSCLK_1      [get_ports sysclk1_clk_p]

create_clock -period 10.000 -name  pcie_refclk [get_ports pcie_refclk_p]

set_false_path -from [get_pins {meep_shell_inst/axi_gpio_0/U0/gpio_core_1/Not_Dual.gpio_Data_Out_reg*/C}]