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


set p_EAdefFile     $g_root_dir/accelerator/meep_shell/accelerator_def.txt
set p_ShellEnvFile  $g_root_dir/tcl/shell_env.tcl


################################################################
# Create a Physical Interface Enabled List. Needs a valid
# list of shell enabled interfaces
# Returns the enabled elements of the following physical available interfaces list:
# set PortInterfacesList  [list pcie ddr4 aurora ethernet uart ]
################################################################
proc PortInterfaceDefinition { PortInterfacesList EnabledIntf ShellEnvFile} {

	set fd_ShellEnv    [open $ShellEnvFile "a"]

	set PortEnabledList [list pcie]
	
	set EnIntfNameList [list]
	
	foreach dicEntry $EnabledIntf {
		#putmeeps "DEBUG ENTRY: $dicEntry"		
		set EnIntfNameList [lappend EnIntfNameList [dict get $dicEntry Name]]		
		#putmeeps "DEBUG PORTS: $EnIntfNameList"
	}
	set EnIntfName [join $EnIntfNameList]

	foreach PhysIntf $PortInterfacesList {
		
		if {[regexp -inline -all -nocase $PhysIntf "$EnIntfName"] ne ""} {
			set PortEnabledList [lappend PortEnabledList $PhysIntf]
			putmeeps "DEBUG: Show enabled physical Intf - $PhysIntf"
		}		
	}
	
	puts $fd_ShellEnv "set PortEnabledList \[list [join [list $PortEnabledList]]\]"
	
	close $fd_ShellEnv

}


################################################################
# Parse the EA interfaces and create the shell environment file.
# Returns a dictionary of the following Shell available interfaces:
# set ShellInterfacesList [list PCIE DDR4 HBM AURORA ETHERNET UART ]
# *HBM will be returned as HBMn, where n is a channel identificator
# TODO: Choosing to what HBM pseudochannel to be connected
# TODO: Choose different clocks for different instances of the same interface.
################################################################
proc ShellInterfaceDefinition { ShellInterfacesList ClockList DefinitionFile ShellEnvFile} {

	set fd_AccDef      [open $DefinitionFile "r"]
	set fd_ShellEnv    [open $ShellEnvFile "w"]
	
	# PCIe is not enabled by default.
	set EnabledIntf {}
	
	putmeeps "OLKASE FIRST CLOCKS $ClockList"
	
		
	while {[gets $fd_AccDef line] >= 0} {
	
		set line [string map {" " ""} $line]
	
		set fields [split $line ","]
	
		foreach device $ShellInterfacesList {
		
		# putmeeps "DEBUG: [lindex $fields 0]"
		# putmeeps "DEBUG: [lindex $fields 1]"
		# putmeeps "DEBUG: [lindex $fields 2]"
		
			if { [lindex $fields 0] == "${device}" && [lindex $fields 1] == "yes" } {	
				# Dont push to the user to number his interfaces when there is only one.							
				for {set i 0} {$i < [lindex $fields 3] } {incr i} {
					if {[lindex $fields 3] == 1} {	
						set n ""
					} else {
						set n $i
					}
					set d_device [dict create Name g_${device}${n}]
					dict set d_device IntfLabel [lindex $fields 2]${n}
					dict set d_device SyncClk   [lindex $fields 4] Freq ""
					dict set d_device SyncClk   [lindex $fields 4] Name ""
					dict set d_device AxiIntf "Axi4"
					
					## If the Interface has an associated clock, add it to the dict
					foreach vclocks $ClockList {						
						if {[lindex $vclocks 0] == [lindex $fields 4] } {
							dict set d_device SyncClk [lindex $fields 4] Freq [lindex $vclocks 1]
							dict set d_device SyncClk [lindex $fields 4] Name [lindex $vclocks 2]
						}
					}
					
					### Device-dependant settings
					if { "${device}" == "UART" } {
						dict set d_device Mode [lindex $fields 5]	
						dict set d_device IRQ  [lindex $fields 6]	
						dict set d_device AxiIntf "AxiL"
						if { [lindex $fields 5] != "normal" } {
							dict set d_device AxiIntf "no"						
						} 
					}
					set EnabledIntf [lappend EnabledIntf "$d_device"]					
				}
			}
		}	
	}
	
	puts $fd_ShellEnv "set ShellEnabledIntf \[list [join [list $EnabledIntf]]\]"
	putmeeps "\[INFO\] Shell enabled interfaces: $EnabledIntf"
		
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
	
		set fields [split $line ","]
				
			if { [regexp -all -inline {^CLK.,} $line] ne "" } {					
				set g_CLK [list CLK${i} [lindex $fields 1] [lindex $fields 2]]
				set RetList [lappend RetList $g_CLK]
				incr i	
			}						
	}
	
	close $fd_AccDef
	
	return $RetList
}

putmeeps "\[INFO\] Starting shell definition process..."

set ClockList [ClocksDefinition $p_EAdefFile ]

set EnabledIntf [ShellInterfaceDefinition $ShellInterfacesList $ClockList $p_EAdefFile $p_ShellEnvFile]

putmeeps "Dictionary $EnabledIntf ..."


PortInterfaceDefinition $PortInterfacesList $EnabledIntf $p_ShellEnvFile


putcolors "Shell enviroment file created on $p_ShellEnvFile" $GREEN
