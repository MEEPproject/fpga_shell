# This clocks drives the DDR reference clock, constrained by the MIG IP
#create_clock -period 3.333 -name SYSCLK_0      [get_ports sysclk0_clk_p]


# The clock below doesn't need to be created as it is fixed to the MMCM and it creates the constraint itself
#create_clock -period 10.000 -name SYSCLK_1      [get_ports sysclk1_clk_p]

create_clock -period 10.000 -name  pcie_refclk [get_ports pcie_refclk_clk_p]

# Hierarchy is fixed for the MEEP Shell
set_false_path -from [get_pins {meep_shell_inst/axi_gpio_0/U0/gpio_core_1/Not_Dual.gpio_Data_Out_reg*/C}]
