# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Daniel J.Mazure, BSC-CNS
# Date: 22.02.2022
# Description: 


#define_shell.tcl

namespace eval _tcl {
proc get_script_folder {} {
    set script_path [file normalize [info script]]
    set script_folder [file dirname $script_path]
    return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]
puts "The environment tcl will be sourced from ${script_folder}"

source $script_folder/environment.tcl
source $g_root_dir/tcl/procedures.tcl

set g_acc_dir $g_root_dir/accelerator

set p_ShellEnvFile  $g_root_dir/tcl/shell_env.tcl
set p_EAdefFile     $g_acc_dir/meep_shell/accelerator_def.csv
set p_EAmodFile	    $g_acc_dir/meep_shell/accelerator_mod.sv


################################################################
# Create a Physical Interface Enabled List. Needs a valid
# list of shell enabled interfaces
# Returns the enabled elements of the following physical available interfaces list:
# set PortInterfacesList  [list pcie ddr4 aurora ethernet uart ]
################################################################
proc PortInterfaceDefinition { PortInterfacesList EnabledIntf} {

	set PortEnabledList [list pcie]
	
	set EnIntfNameList [list]
	set RetString ""
	
	foreach dicEntry $EnabledIntf {
		#putmeeps "DEBUG ENTRY: $dicEntry"		
		set EnIntfNameList [lappend EnIntfNameList [dict get $dicEntry Name]]		
		#putmeeps "DEBUG PORTS: $EnIntfNameList"
	}
	set EnIntfName [join $EnIntfNameList]

	foreach PhysIntf $PortInterfacesList {
		
		if {[regexp -inline -all -nocase $PhysIntf "$EnIntfName"] ne ""} {
			set PortEnabledList [lappend PortEnabledList $PhysIntf]
			putmeeps "Show enabled physical Intf - $PhysIntf"
		}		
	}
	
	set RetString "\[list [join [list $PortEnabledList]]\]"
		
	return $RetString
}


################################################################
# Parse the EA interfaces and create the shell environment file.
# Returns a dictionary of the following Shell available interfaces:
# set ShellInterfacesList [list PCIE DDR4 HBM AURORA ETHERNET UART ]
# *HBM will be returned as HBMn, where n is a channel identifier
# TODO: Choosing to what HBM pseudochannel to be connected
# TODO: Choose different clocks for different instances of the same interface.
################################################################
proc ShellInterfaceDefinition { ShellInterfacesList ClockList DefinitionFile ShellEnvFile EAModFile} {

	set fd_AccDef      [open $DefinitionFile "r"]
	set fd_ShellEnv    [open $ShellEnvFile "w"]
	
	# PCIe is not enabled by default.
	set EnabledIntf {}
		
		
	while {[gets $fd_AccDef line] >= 0} {
	
		set line [string map {" " ""} $line]
		set line [string map {"\t" ""} $line]	
	
		set fields [split $line ","]
	
		foreach device $ShellInterfacesList {
		
		#putmeeps "DEBUG: FIELDS: $fields"			
		
			if { [lindex $fields 0] == "${device}" && [lindex $fields 1] == "yes" } {	

				# Dont push to the user to number his interfaces when there is only one.							
				# TODO: Parse $fields 3 to secuere that it is in fact a number
				for {set i 0} {$i < [lindex $fields 3] } {incr i} {
					if {[lindex $fields 3] == 1} {	
						set n ""
					} else {
						set n $i
					}
					set d_device [dict create Name g_${device}${n}]
					dict set d_device IntfLabel [lindex $fields 2]${n}
					# Create empty fields to be filled later
					dict set d_device SyncClk   [lindex $fields 4] Freq ""
					dict set d_device SyncClk   [lindex $fields 4] Name ""
					dict set d_device AxiIntf "Axi4"
					dict set d_device BaseAddr [lindex $fields 5]
					# set BROMMemRange [expr {2**$BROMaddrWidth/1024}]
					set IntfLabel [dict get $d_device IntfLabel]
					set axivalues [ get_axi_properties $EAModFile $IntfLabel ]

					dict set d_device "AxiAddrWidth" [lindex $axivalues 0]
					dict set d_device "AxiDataWidth" [lindex $axivalues 1]
					dict set d_device "AxiIdWidth"   [lindex $axivalues 2]
					dict set d_device "AxiUserWidth" [lindex $axivalues 3]

					## If the Interface has an associated clock, add it to the dict
					foreach vclocks $ClockList {	
						set ClkNum  [dict get $vclocks ClkNum]
						if { $ClkNum == [lindex $fields 4] } {
							set ClkValue [dict get $vclocks ClkNum]
							set ClkFreq  [dict get $vclocks ClkFreq]
							set ClkName  [dict get $vclocks ClkName]
							set ClkList [list Label $ClkValue Freq $ClkFreq Name $ClkName]
							putmeeps "$device Clk: ${ClkFreq}Hz ${ClkName}"
							dict set d_device SyncClk $ClkList
						}
					}
					## If the interface is synchronous to the PCIe CLK, create an special case
					if { [lindex $fields 4] == "PCIE_CLK" } {
						set ClkFreq 250000000
						set ClkName "PCIE_CLK"
						set ClkList [list Freq $ClkFreq Name $ClkName]
						putmeeps "$device Clk: ${ClkFreq}Hz ${ClkName}"
						dict set d_device SyncClk $ClkList

					}
					
					### Device-dependant settings
					if { "${device}" == "PCIE" } {
						dict set d_device IntfLabel  [lindex $fields 2]
						dict set d_device ClkName    [lindex $fields 5]
                                                dict set d_device RstName    [lindex $fields 6]
						dict set d_device Mode       [lindex $fields 7]
						dict set d_device SliceRegEn [lindex $fields 8]
					}	
					if { "${device}" == "UART" } {
						dict set d_device Mode [lindex $fields 6]	
						dict set d_device IRQ  [lindex $fields 7]	
						dict set d_device AxiIntf "AxiL"
						if { [lindex $fields 5] != "normal" } {
							dict set d_device AxiIntf "no"						
						} 
					}
					if { "${device}" == "HBM" } {
						dict set d_device CalibDone [lindex $fields 6]	
						dict set d_device EnChannel [lindex $fields 7]
					}
					if { "${device}" == "BROM" } {
						dict set d_device InitFile [lindex $fields 6]	
					}
					if { "${device}" == "ETHERNET" } {
                                                dict set d_device IRQ [lindex $fields 7]
					}
					if { "${device}" == "AURORA" } {
                                                dict set d_device Mode   [lindex $fields 6]
                                                dict set d_device UsrClk [lindex $fields 8]
					}
					set EnabledIntf [lappend EnabledIntf "$d_device"]					
				}
			}
		}	
	}
	puts $fd_ShellEnv "set ShellEnabledIntf \[list [join [list $EnabledIntf]]\]"
	#putmeeps $fd_ShellEnv "set ShellEnabledIntf \[list [join [list $EnabledIntf]]\]"
	#putmeeps "Shell enabled interfaces: $EnabledIntf"
		
	close $fd_AccDef
	close $fd_ShellEnv
	
	return $EnabledIntf
}


################################################################
# Parse the EA clocks. Create a list of clocks, frequencies and names
################################################################
proc ClocksDefinition { DefinitionFile } {

	set fd_AccDef      [open $DefinitionFile "r"]

	set RetList [list]
	
	set i 0
	
	
	while {[gets $fd_AccDef line] >= 0} {
	
	set line [string map {" " ""} $line]
	set line [string map {"\t" ""} $line]
	### TODO: Remove also tabs
	
		set fields [split $line ","]
				
			if { [regexp -all -inline {^CLK.,} $line] ne "" } {	

				set d_clock [dict create Name CLK${i}]
				dict set d_clock ClkNum    [lindex $fields 0]
				dict set d_clock ClkFreq   [lindex $fields 1]
				dict set d_clock ClkName   [lindex $fields 2]
				dict set d_clock ClkRst    [lindex $fields 3]
				dict set d_clock ClkRstPol [lindex $fields 4]
			
				set RetList [lappend RetList $d_clock]
				incr i	
			}						
	}
	
	close $fd_AccDef
	
	return $RetList
}

################################################################
# Parse the definiton file. Check correctness
################################################################
proc parse_definiton_file { DefinitionFile } {

	set fd_AccDef      [open $DefinitionFile "r"]
	set storeClockList [list]
	set ret 0
	

	while {[gets $fd_AccDef line] >= 0} {
		if {[regexp -inline -all {[\t|\s]+} $line] ne ""} {
			putwarnings "The definition file contains white spaces. Check \
			the definition file. \r\n\tDetected in line: $line"
			set ret 1
		}	
		if {[regexp -inline -all {yes,.*} $line] ne ""} {
                        if {[regexp -inline -all {PCIE_CLK} $line] != ""} {
			putmeeps "The interface is synchronous to PCIe CLK"

			} elseif {[regexp -inline -all {CLK\d} $line] eq ""} {
			puterrors "The interface is enabled but doesn't have a valid clock.\
			\r\n\tDetected in line: $line"
			set ret 2
			break			
			} else {
				set storeClockList [lappend storeClockList [regexp -inline -all {CLK\d} $line]]
			}
		}
		if {[regexp -inline -all {^CLK\d} $line] ne ""} {
			set capturedClockList [lappend capturedClockList [regexp -inline -all {^CLK\d} $line]]
		}

	}
	
	## Compare the clocks declared in the defined list against those linked to the interfaces
	foreach storedClock $storeClockList {
		set ClockError  1
		# A detection must happend for the error flag to be disabled
		foreach capturedClock $capturedClockList {
			if {$storedClock == $capturedClock} {
				set ClockError  0
			}
		}
		if { $ClockError == 1 } {
			puterrors "Missing clock for interfaces"
			set ret 2
		}
	}
	
	close $fd_AccDef
		
	return $ret
}

################################################################
# Parse the PCIe GPIO. Only Outputs. 
# TODO: GPIO inputs can be added as another dictionary in the same
# 	  : list 
################################################################
proc GPIODefinition { DefinitionFile } {

	set fd_AccDef      [open $DefinitionFile "r"]
	set d_gpio ""
	
			
	while {[gets $fd_AccDef line] >= 0} {
		set line [string map {" " ""} $line]	
		set line [string map {"\t" ""} $line]	
		if {[regexp -inline -all {^GPIO,} $line] ne ""} {
			set fields [split $line ","]	
			# GPIO width is the second field
			set d_gpio [dict create Name g_gpio]
			dict set d_gpio Width     [lindex $fields 1]
			dict set d_gpio IntfLabel [lindex $fields 2]
			dict set d_gpio InitValue [lindex $fields 3]
			
			# The Initial value is received as an hexadecimal string: 0xABDC
			# string map can be called to remove "0x". Then do:
			# binary scan [binary format H* $hex] B* bits					
			#putmeeps "Adding GPIO to the list: $d_gpio "
		}		
	}
	
	close $fd_AccDef

	return $d_gpio
}

################################################################
# Discover the asynchronous reset signal. This signal resets 
# the whole shell but the PCIe interface.
################################################################
proc ARstDefinition { DefinitionFile } {

	set fd_AccDef      [open $DefinitionFile "r"]
	set d_rst ""
	
			
	while {[gets $fd_AccDef line] >= 0} {
		set line [string map {" " ""} $line]	
		set line [string map {"\t" ""} $line]	
		if {[regexp -inline -all {^ARST,} $line] ne ""} {
			set fields [split $line ","]	
			
			set d_rst [dict create Name g_rst]
			dict set d_rst Polarity  [lindex $fields 1]
			dict set d_rst IntfLabel [lindex $fields 2]
			
			#putmeeps "Adding GPIO to the list: $d_gpio "
		}		
	}
	
	close $fd_AccDef

	return $d_rst
}

################################################################
# Get the EA name so it is shown later
################################################################
proc GetEAname { DefinitionFile } {

	set fd_AccDef      [open $DefinitionFile "r"]
	set i 0 
	set ModuleName ""
	
	while {[gets $fd_AccDef line] >= 0} {
		if {[regexp -inline -all {^EANAME} $line] ne ""} {
			set fields [split $line "="]
			set ModuleName [lindex $fields 1]			
			putmeeps "Found module name **$ModuleName** at line $i" 
			incr i
			break
		}		
	}
		
    return $ModuleName
}

###############################################################
## MEEP SHELL GENERATION STARTS
###############################################################

putmeeps "Starting shell definition process..."

set ParseRet [parse_definiton_file $p_EAdefFile]

if { $ParseRet == 1 } {
	putmeeps "INFO: Whitespaces detected. This is not an error but \
	it is suggested to clean the definition file"
	#exit 1	
} 
if { $ParseRet == 2 } {
	puterrors "Clock parsing failed"
	exit 1	
}


set ClockList [ClocksDefinition $p_EAdefFile ]
set GPIOList  [GPIODefinition $p_EAdefFile ]
set ARSTDef   [ARstDefinition $p_EAdefFile ]
set EAname    [GetEAname $p_EAdefFile ]


putmeeps "GPIO List: $GPIOList"

set EnabledIntf [ShellInterfaceDefinition $ShellInterfacesList $ClockList $p_EAdefFile $p_ShellEnvFile $p_EAmodFile]

set PortInt [PortInterfaceDefinition $PortInterfacesList $EnabledIntf]

putmeeps "$PortInt"
## Add the Port Interface list to the environment file
Add2EnvFile $p_ShellEnvFile "set PortEnabledList $PortInt"
## Add the GPIO list to the environment file
Add2EnvFile $p_ShellEnvFile "set GPIOList \{$GPIOList\}"
## Add the Clock list to the environment file
Add2EnvFile $p_ShellEnvFile "set ClockList \[list $ClockList\]"
## Add the Async Reset to the environment file
Add2EnvFile $p_ShellEnvFile "set ARSTDef \[list $ARSTDef\]"
## Add the EA name to the environment file
Add2EnvFile $p_ShellEnvFile "set g_EAname $EAname"



putcolors "Shell enviroment file created on $p_ShellEnvFile" $GREEN
