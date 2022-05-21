# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Solderpad Hardware License v 2.1 (the "License");
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
# 
#     http://www.solderpad.org/licenses/SHL-2.1
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Daniel J.Mazure, BSC-CNS
# Date: 22.02.2022
# Description: 


## TODO: Cover repeated interfaces: 2 AURORA, 2 ETHERNET... etc.
## 	   : Incompatibilities: Can't use 2 Aurora and 2 Ethernet (Limited QSFP)

set g_system_file   $g_root_dir/interfaces/system.sv
set g_pcie_file     $g_root_dir/interfaces/pcie.sv
set g_ddr4_file     $g_root_dir/interfaces/ddr4.sv
set g_aurora0_file  $g_root_dir/interfaces/aurora0.sv
set g_aurora1_file  $g_root_dir/interfaces/aurora1.sv
set g_Eth0_file     $g_root_dir/interfaces/ethernet0.sv
set g_Eth1_file     $g_root_dir/interfaces/ethernet1.sv
set g_uart_file     $g_root_dir/interfaces/uart.sv

# Create a list with the physical ports file handler
# When an interface is detected, the file path is added to the list
# That list will be used to create the top level ports in the module
# definition.

set PortList [list]

# Source the shell definition parameters
source $g_root_dir/tcl/shell_env.tcl

# Create the Vivado block desing structure & placeholder
source $g_root_dir/shell/shell_base.tcl

# Create the clock structure
source $g_root_dir/shell/shell_mmcm.tcl
# Added by definition
add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/hbm_${g_board_part}.xdc"

##if {[info exists $shellIntf]} 

foreach dicEntry $ShellEnabledIntf {

	set IntfName [dict get $dicEntry Name]

	if {[regexp -inline -all "PCIE" $IntfName] ne "" } {
                set PCIEentry $dicEntry
                source $g_root_dir/shell/shell_qdma.tcl
                add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/qdma_${g_board_part}.xdc"
        }

		
	if {[regexp -inline -all "DDR4" $IntfName] ne "" } {
		set DDR4entry $dicEntry
		source $g_root_dir/shell/shell_ddr4.tcl
		add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/ddr4_${g_board_part}.xdc"		
	} 
	
	if {[regexp -inline -all "HBM" $IntfName] ne "" } {
		set HBMentry $dicEntry
		source $g_root_dir/shell/shell_hbm.tcl		
		set_property CONFIG.ASSOCIATED_BUSIF $HBMintf [get_bd_ports /$HBMname]
	}

	if {[regexp -inline -all "UART" $IntfName] ne "" } {
		set UARTentry $dicEntry
		source $g_root_dir/shell/shell_uart.tcl
		add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/uart_${g_board_part}.xdc"		
	}

	if {[regexp -inline -all "ETHERNET" $IntfName] ne "" } {
		set ETHentry $dicEntry
		set ETHrate  [dict get $ETHentry GbEth]
		set ETHqsfp  [dict get $ETHentry qsfpPort]
		source $g_root_dir/shell/shell_${ETHrate}Ethernet.tcl
		add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/ethernet${ETHrate}_${ETHqsfp}_${g_board_part}.xdc"
		set_property CONFIG.ASSOCIATED_BUSIF $ETHintf [get_bd_ports /$ETHClkName]
		# TODO: Check if ETHClkName is the right label. HBM uses "$HBMName"
		# TODO: Physicall QSFP constrains can be part of the IP

	}
	if {[regexp -inline -all "AURORA" $IntfName] ne "" } {
		set AURORAentry $dicEntry
		source $g_root_dir/shell/shell_aurora.tcl
		add_files -fileset [get_filesets constrs_1] "$g_root_dir/xdc/$g_board_part/aurora_${g_board_part}.xdc"		
	}
	if {[regexp -inline -all "BROM" $IntfName] ne "" } {
		set BROMentry $dicEntry
		source $g_root_dir/shell/shell_brom.tcl
	}
        if {[regexp -inline -all "BRAM" $IntfName] ne "" } {
                set BRAMentry $dicEntry
                source $g_root_dir/shell/shell_bram.tcl
        }	
	
}

#GEnerate IF GPIO: Inside the tcl

source $g_root_dir/shell/shell_gpio.tcl


## TODO: Find the right place for this, as lools like the smartConnect
## needs to be present for this to get set
#set_property CONFIG.ASSOCIATED_BUSIF $HBMintf [get_bd_ports /$HBMname]
#set_property CONFIG.ASSOCIATED_BUSIF $ETHintf [get_bd_ports /$ETHClkName]

### TODO: Catch
source $g_root_dir/shell/shell_memmap.tcl

update_ip_catalog -rebuild -scan_changes
 
validate_bd_design

save_bd_design 
