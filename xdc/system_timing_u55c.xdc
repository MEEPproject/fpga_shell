create_clock -period 10.000 -name sysclk2      [get_ports sysclk2_clk_p]
create_clock -period 10.000 -name sysclk3      [get_ports sysclk3_clk_p] 
create_clock -period 10.000 -name sysclk4      [get_ports sysclk4_clk_p]

create_clock -period 10.000 -name  pcie_refclk [get_ports pcie_refclk_p]

set_false_path -from [get_pins {meep_shell_inst/axi_gpio_0/U0/gpio_core_1/Not_Dual.gpio_Data_Out_reg*/C}]
