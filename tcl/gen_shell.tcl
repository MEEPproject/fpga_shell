## TODO: Cover repeated interfaces: 2 AURORA, 2 ETHERNET... etc.
## 	   : Incompatibilities: Can't use 2 Aurora and 2 Ethernet (Limited QSFP)

# Source the shell definition parameters
source $g_root_dir/tcl/shell_env.tcl

# Create the Vivado block desing structure & placeholder
source $g_root_dir/shell/shell_base.tcl

# Create the PCIe strucutre
source $g_root_dir/shell/shell_qdma.tcl
# Added by definition
add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/qdma_${g_board_part}.xdc"
add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/hbm_${g_board_part}.xdc"

##if {[info exists $shellIntf]} 

foreach dicEntry $ShellEnabledIntf {

	set IntfName [dict get $dicEntry Name]
		
	if {[regexp -inline -all "DDR4" $IntfName] ne "" } {
		set DDR4entry $dicEntry
		source $g_root_dir/shell/shell_ddr4.tcl
		add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/ddr4_${g_board_part}.xdc"		
	} 
	
	if {[regexp -inline -all "HBM" $IntfName] ne "" } {
		set HBMentry $dicEntry
		source $g_root_dir/shell/shell_hbm.tcl		
	}

	if {[regexp -inline -all "UART" $IntfName] ne "" } {
		set UARTentry $dicEntry
		source $g_root_dir/shell/shell_uart.tcl
		add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/uart_${g_board_part}.xdc"		
	}

	if {[regexp -inline -all "ETHERNET" $IntfName] ne "" } {
		set ETHERNETentry $dicEntry
		source $g_root_dir/shell/shell_ethernet.tcl
		add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/ethernet_${g_board_part}.xdc"		
	}
	if {[regexp -inline -all "AURORA" $IntfName] ne "" } {
		set AURORAentry $dicEntry
		source $g_root_dir/shell/shell_aurora.tcl
		add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/aurora_${g_board_part}.xdc"		
	}
	
}

#GEnerate IF GPIO

if {[info exists GPIOList]} {
	putdebugs "Calling to GPIO: $GPIOList"
	source $g_root_dir/shell/shell_gpio.tcl
}

source $g_root_dir/shell/shell_connect.tcl

## TODO: Find the right place for this, as lools like the smartConnect
## needs to be present for this to get set
set_property CONFIG.ASSOCIATED_BUSIF $HBMintf [get_bd_ports /$HBMname]

 
source $g_root_dir/shell/shell_memmap.tcl
 
save_bd_design 
validate_bd_design

save_bd_design 
