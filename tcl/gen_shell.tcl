# Source the shell definition parameters
source $g_root_dir/tcl/shell_env.tcl

# Create the Vivado block desing structure & placeholder
source $g_root_dir/shell/shell_base.tcl

# Create the PCIe strucutre
source $g_root_dir/shell/shell_qdma.tcl
# Added by definition
add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/qdma_alveo280.xdc"


if { $g_DDR4 eq "yes"} {
	source $g_root_dir/shell/shell_ddr4.tcl
} elseif { $g_HBM eq "yes"} {
	source $g_root_dir/shell/shell_hbm.tcl
}

if { $g_UART eq "yes"} {
	source $g_root_dir/shell/shell_uart.tcl
	add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/uart_alveo280.xdc"
}

if { $g_BROM eq "yes"} {
	source $g_root_dir/shell/shell_brom.tcl
}

#GEnerate IF GPIO
source $g_root_dir/shell/shell_gpio.tcl

source $g_root_dir/shell/shell_memmap.tcl
 


save_bd_design 
validate_bd_design

