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

#################################################################
# This list the shell capabilities. Add more interfaces when they 
# are ready to be implemented. XDC FPGA Board file could be used.
#################################################################
set ShellInterfacesList [list PCIE DDR4 HBM AURORA ETHERNET UART ]

## List here the physical interfaces. Lowercase as they are connected
## to file names. 
set PortInterfacesList  [list pcie ddr4 aurora ethernet uart ]

set p_EAdefFile     $g_root_dir/accelerator/meep_shell/accelerator_def.txt
set p_ShellEnvFile  $g_root_dir/tcl/shell_env.tcl


################################################################
# Create a Physical Interface Enabled List. Needs a valid
# list of shell enabled interfaces
################################################################
proc PortInterfaceDefinition { PortInterfacesList EnabledIntf ShellEnvFile} {

	set fd_ShellEnv    [open $ShellEnvFile "a"]

	set PortEnabledList [list pcie]
	set EnabledIntf [join $EnabledIntf]

	foreach PhysIntf $PortInterfacesList {
		
		if {[regexp -inline -all -nocase $PhysIntf "$EnabledIntf"] ne ""} {
			set PortEnabledList [lappend PortEnabledList $PhysIntf]
			putmeeps "DEBUG: Show enabled physical Intf - $PhysIntf"
		}		
	}
	
	puts $fd_ShellEnv "set PortEnabledList \[list [join [list $PortEnabledList]]\]"
	
	close $fd_ShellEnv

}

################################################################
# Create the list of the files corresponding to enabled Port
# interfaces.
################################################################


################################################################
# Parse the EA interfaces and create the shell environment file.
################################################################
proc ShellInterfaceDefinition { ShellInterfacesList DefinitionFile ShellEnvFile} {

	set fd_AccDef      [open $DefinitionFile "r"]
	set fd_ShellEnv    [open $ShellEnvFile "w"]
	
	# PCIe is not enabled by default.
	set EnabledIntf [list]
		
	while {[gets $fd_AccDef line] >= 0} {
	
		set fields [split $line ","]
	
		foreach device $ShellInterfacesList {
		
		# putmeeps "DEBUG: [lindex $fields 0]"
		# putmeeps "DEBUG: [lindex $fields 1]"
		# putmeeps "DEBUG: [lindex $fields 2]"
		
			if { [lindex $fields 0] == "${device}" && [lindex $fields 1] == "yes" } {								
			## HBM can have multiple AXI interfaces. They need to be named differently
				if { [lindex $fields 0] == "HBM" } {
					for {set i 0} {$i < [lindex $fields 3] } {incr i} {
						#puts "I inside first loop: $i"
						set EnabledIntf [lappend EnabledIntf "g_${device}${i}"]	
						puts $fd_ShellEnv "set g_${device}${i} \[list [lindex $fields 2]${i}\]"
					}			
				} else {
				# Normal path, not HBM
					set EnabledIntf [lappend EnabledIntf "g_${device}"]	
					puts $fd_ShellEnv "set g_${device} \[list [lindex $fields 2]\]"
					#putmeeps "DEBUG: [lindex $fields 0]"
				}
			}
		}	
		#if {[info exists $shellIntf]} {
			#set EnabledIntf [lappend EnabledIntf $shellIntf]
		#}
	}
	
	puts $fd_ShellEnv "set ShellEnabledIntf \[list [join [list $EnabledIntf]]\]"
	putmeeps "\[INFO\] Shell enabled interfaces: $EnabledIntf"
		
	close $fd_AccDef
	close $fd_ShellEnv
	
	return $EnabledIntf
}


###################################################
# Parse the EA clocks. Create a list of clocks, frequencies and names
###################################################
proc ClocksDefinition { DefinitionFile ShellEnvFile } {

	set fd_AccDef      [open $DefinitionFile "r"]
	set fd_ShellEnv    [open $ShellEnvFile  "a"]	
	
	set i 0
		
	while {[gets $fd_AccDef line] >= 0} {
	
	set line [string map {" " ""} $line]
	
		set fields [split $line ","]
				
			if { [regexp -all -inline {^CLK.,} $line] ne "" } {					
				puts $fd_ShellEnv "set g_CLK${i} \[list CLK${i} [lindex $fields 1] [lindex $fields 2]\]"
				incr i	
			}						
	}
	
	close $fd_AccDef
	close $fd_ShellEnv

}

set EnabledIntf [ShellInterfaceDefinition $ShellInterfacesList $p_EAdefFile $p_ShellEnvFile]

ClocksDefinition $p_EAdefFile $p_ShellEnvFile

PortInterfaceDefinition $PortInterfacesList $EnabledIntf $p_ShellEnvFile




putcolors "Shell enviroment file created on $p_ShellEnvFile" $GREEN
