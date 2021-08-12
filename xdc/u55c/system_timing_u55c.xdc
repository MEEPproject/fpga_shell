#IMPORTANT: sysclk0 is sysclk2 in the u55c master xdc file. sysclk1 is sysclk3
#For u280 compatibility reasons

create_clock -period 10.000 -name SYSCLK_2      [get_ports sysclk0_clk_p]
#create_clock -period 10.000 -name SYSCLK_3      [get_ports sysclk1_clk_p] 
#create_clock -period 10.000 -name sysclk4      [get_ports sysclk2_clk_p]

create_clock -period 10.000 -name  pcie_refclk [get_ports pcie_refclk_clk_p]

set_false_path -from [get_pins {meep_shell_inst/axi_gpio_0/U0/gpio_core_1/Not_Dual.gpio_Data_Out_reg*/C}]
