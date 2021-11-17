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

###################################################
# This list the shell capabilities. Add more interfaces when they are ready to be 
# implemented
###################################################
set ShellInterfacesList [list DDR4 HBM AURORA ETHERNET UART ]
set p_EAdefFile     $g_root_dir/accelerator/meep_shell/accelerator_def.txt
set p_ShellEnvFile $g_root_dir/tcl/shell_env.tcl


###################################################
# Parse the EA interfaces
###################################################
proc InterfaceDefinition { ShellInterfacesList DefinitionFile ShellEnvFile} {

	set fd_AccDef      [open $DefinitionFile "r"]
	set fd_ShellEnv    [open $ShellEnvFile "w"]

	set EnabledInft [list]
		
	while {[gets $fd_AccDef line] >= 0} {
	
		set fields [split $line ","]
	
		foreach device $ShellInterfacesList {
		
		putmeeps "DEBUG: [lindex $fields 0]"
		putmeeps "DEBUG: [lindex $fields 1]"
		putmeeps "DEBUG: [lindex $fields 2]"
		
			if { [lindex $fields 0] == "${device}" && [lindex $fields 1] == "yes" } {								
			## HBM can have multiple AXI interfaces. They need to be named differently
				if { [lindex $fields 0] == "HBM" } {
					for {set i 0} {$i < [lindex $fields 3] } {incr i} {
						puts "I inside first loop: $i"
						set EnabledInft [lappend EnabledInft "g_${device}${i}"]	
						puts $fd_ShellEnv "set g_${device}${i} [lindex $fields 2]${i}"
					}			
				} else {
				# Normal path, not HBM
					set EnabledInft [lappend EnabledInft "g_${device}"]	
					puts $fd_ShellEnv "set g_${device} [lindex $fields 2]"
					putmeeps "DEBUG: [lindex $fields 0]"
				}
			}
		}	
		#if {[info exists $shellIntf]} {
			#set EnabledInft [lappend EnabledInft $shellIntf]
		#}
	}
	
	
	putmeeps "\[INFO\] Shell enabled interfaces: $EnabledInft"
		
	close $fd_AccDef
	close $fd_ShellEnv
	
	return $EnabledInft
}


###################################################
# Parse the EA clocks. Create a list of clocks, frequencies and names
###################################################
proc ClocksDefinition { DefinitionFile ShellEnvFile } {

	set fd_AccDef      [open $DefinitionFile "r"]
	set fd_ShellEnv    [open $ShellEnvFile  "a"]

	set EnabledClocks [list]
		
	while {[gets $fd_AccDef line] >= 0} {
	
		set fields [split $line ","]
		
	}

}

InterfaceDefinition $ShellInterfacesList $p_EAdefFile $p_ShellEnvFile


putcolors "Shell enviroment file created on $p_ShellEnvFile" $GREEN