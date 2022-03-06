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


set RED "\033\[1;31m"
set GREEN "\033\[1;32m"
set YELLOW "\033\[1;33m"
set CYAN "\033\[1;36m"
set RESET "\033\[0m"



proc putcolors { someText color } {

	set RESET "\033\[0m"

	puts "${color}\[MEEP\] INFO: ${someText}${RESET}"

}

proc putmeeps { someText } {        

	puts "\[MEEP\] INFO: ${someText}"

}

proc puterrors { someText } {

	set RED "\033\[1;31m"
	set RESET "\033\[0m"

	puts "${RED}\[MEEP\]\ ERROR: ${RESET}${someText}"
	
	return 1
}

proc putwarnings { someText } {

	set YELLOW "\033\[1;33m"
	set RESET "\033\[0m"

	puts "${YELLOW}\[MEEP\]\ WARNING: ${RESET}${someText}"
}

proc putdebugs { someText } {

	global DebugEnable

	set CYAN "\033\[1;36m"
	set RESET "\033\[0m"
	
	if { $DebugEnable == True } {
		puts "${CYAN}\[MEEP\]\ DEBUG: ${RESET}${someText}"
	}
}

# Create EA instance using the EA top module as template. This function takes the inputs/outpus
# and uses them to create a system verilog instance using the formula ".mySignal (mySignal)"
# It also creates the wires along the way, as they will be used to connect to the Shell. The wires
# are stored in a separated file.
# It can skip blank lines and comments.
# EA ports <---> EA wires

proc parse_module {fd_mod fd_inst fd_wire fd_shell} {	

	set doConnection 0
	set moduleParsed 0
	set ret 0
	
	set comma ""
	

	while {[gets $fd_mod line] >= 0} {
	
	# Look for the module name. Expecting something similar to a wrapper.
	# Use a condition to not do it in every line once it has been discovered.
		if { $moduleParsed == 0} {

		# module system_wrapper returns a single word separated by spaces
                        if { [regexp -inline -all {^\s*//} $line] == ""} {
				set moduleDef [regexp -inline -all {\ymodule\y\s[a-z|A-z|0-9]*} $line]
				if { $moduleDef ne ""} {
			
					set moduleName [join $moduleDef]
					set moduleName [split $moduleName " "]
					set moduleName [lindex $moduleName  1]
					set moduleParsed 1
					puts $fd_inst "$moduleName ${moduleName}_inst \( "
				}
			}
		} else {
		
		# Look for comments at the begining of the line
			if { [regexp -inline -all {^\s*//} $line] ne ""} {
				#putmeeps "INFO: comment line\r\n"	
		# Detect empty lines
			} elseif { [ regexp {^\s*$} $line ] } {
				#putmeeps "INFO: empty line\r\n"	
			} elseif { [ regexp {[(|)]\s*;*\s*$} $line ] } {
				#putmeeps "Module opening/closing"
			} elseif { [ regexp {endmodule} $line ] } {
				#putmeeps "endmodule"	
			} elseif { [ regexp axi_.*user $line ] } {
				putwarnings	"AXI user signals are not supported and will not be connected"
				#putdebugs "[ regexp -inline axi_.*user $line ]"
			} elseif { [regexp -inline -all {\yinput\y|\youtput\y} $line ]  ne ""} {
			
				if { [regexp -inline -all {\ywire\y} $line ]  ne ""} {
					#putmeeps "INFO: 'wire' keyword is not needed, removing ..."
					set line [string map {wire \ } $line]
				}
				
				set line [string map {\[ \ \[} $line]
				set line [string map {\] \]\ } $line]
				
				# Join is used to remove the regexp returning braces. They are placed there
				# by tcl to not to interpted returning brackets.
				
				set MyVector [regexp -all -inline {\[.+\]} $line]
				set MyVector [string map {" " ""} $MyVector]
				set MyVector [join $MyVector]
				
				set MySignal [regexp -inline -all {\s{1}[a-z|A-Z|0-9|-|_]+\s*,*$} $line]
				set MySignal [string map {" " ""} $MySignal]
				# Need to remove the comma, as there is no lookbehind regex in tcl
				set MySignal [string map {"," ""} $MySignal]
				set MySignal [join $MySignal]
				
				set MyWire "wire $MyVector\ $MySignal    ;"
				set MyPortConnection "$comma     .$MySignal     \($MySignal\)    "
										
				puts $fd_inst $MyPortConnection
				puts $fd_wire $MyWire
				
				## Store only port connections to be appended to the shell instance
				puts $fd_shell  "       .$MySignal     \($MySignal\)     , " 
				
				# # The first connection need to be comma-less. Place it thereafter				
				set comma ","
				
				
			} else {
				set ret [puterrors "Not considered branch?...--> $line"]
				#set teclado [read stdin 1]
				#TODO: Use tcl "error" built-in procedure

			}		
		}
	}
	
	puts $fd_inst "    \) ;" 
	
	return $ret
}


################################################
# This function takes the content of the interface files and unify them
# at the top of the TOP module file, meaning this is the actual I/O interface
# of the final system.
################################################

proc add_interface {g_intf_file g_mod_file} {
		
	set fd_intf [open $g_intf_file "r"]
	set fd_mod  [open $g_mod_file  "a"]
	
	while {[gets $fd_intf line] >= 0} {
		set newline $line
		puts $fd_mod $newline
	}		
	close $fd_intf
	close $fd_mod	
}

################################################
# This function creates the connections between the top level ports 
# and the MEEP Shell in the MEEP Shell instance. 
# The instance is closed using hbm_cattrip, which is always required,
# regardless if HBM is actually used or not.
# TOP LEVEL PORTS <---> Shell instance
################################################
proc add_instance { g_fd g_fd_tmp } {

# Receive the top level ports as a parameter and write the connections
# to the file that temporally stores the shell instance
	set NoCattrip 1
		
	while {[gets $g_fd line] >= 0} {
	
	# Seach for three different fields in case we are handling a vector: 
	# input [33:0] MyPort. This can be handled better. Need refactor
	# Seach for "[" and decide this is field 0. Then search for the signal. 
	# The "input" fiedl can be discarded. Lines startig with "//" need to be 
	# discared or the // maintained.

		set fields [regexp -all -inline {\S+} $line]
		
		if { [regexp -inline -all {\[} $line] ne ""} {
		
			set MyVector  [lindex $fields 1]
			set MySignal  [lindex $fields 2]
		
		} else {
		
			set MyVector 0
			set MySignal  [lindex $fields 1]
		
		}
								
		if { [regexp -inline -all {^\s*//} $line] ne ""} {		# TODO: This is NOT checking for "//" at the begining of a line but anywhere in it.
			#putmeeps "// $result"
			set MySignal "// $line"

		} elseif { [string match "" $line ] } {
		
			putmeeps "INFO: Empty line detected\r\n"
			#putmeeps "Empty Line detected"
		} elseif { [regexp -inline -all {hbm_cattrip} $line] ne "" } {
			putmeeps "INFO: skipping hbm_cattrip port"
			set NoCattrip 0
			# hbm_cattrip is used manually to close the instance,
			# so we don't want to make the connection here.
		} else {		
			#puts $result
			set PortConnection  "    .$MySignal     \($MySignal\)    ,"
			puts $g_fd_tmp $PortConnection					
		}			
	}	
	return $NoCattrip	
}


########################################################
# This procedure receives the EA module name and 
# extracts address and data bus widths.
# TODO: This procedure counts on the vector to be declared
#     : always using '0' as the righmost value e.g 63:0
#	  : 1bit vectors are not supported e.g user\[0:0\]
########################################################
proc get_axi_properties { g_wire_file axi_ifname } {

	set awaddrMatch 0
	set wdataMatch  0
	set axiProperties [list]
	set addrWidth 0
	set dataWidth 0
	set IdWidth 0
	set UserWidth 0

	set fd_wire    [open $g_wire_file  "r"]
	
	putmeeps "Inside properties: $axi_ifname"

	while {[gets $fd_wire line] >= 0} { 
		
				
		if {[regexp -inline -all "${axi_ifname}_awaddr" $line] != "" } {		
			set awaddrMatch [regexp -inline -all "[0-9]+.+${axi_ifname}_awaddr" $line]
			#putdebugs "MATCH: ${axi_ifname}_awaddr $awaddrMatch"			
			set addrWidth [regexp -inline  {[0-9]+} $awaddrMatch]			
			set addrWidth [expr $addrWidth + 1]
			putdebugs $addrWidth

		}
						
		if {[regexp -inline -all "${axi_ifname}_wdata" $line] != "" } {
			set wdataMatch  [regexp -inline -all "[0-9]+.+${axi_ifname}_wdata" $line]	
			#putdebugs "MATCH: ${axi_ifname}_wdata $wdataMatch"
			set dataWidth [regexp -inline  {[0-9]+} $wdataMatch]
			set dataWidth [expr $dataWidth + 1]
			putdebugs $dataWidth
		}
		
		if {[regexp -inline -all "${axi_ifname}_awid" $line] != "" } {
			set awidMatch  [regexp -inline -all "[0-9]+.+${axi_ifname}_awid" $line]	
			#putdebugs "MATCH: ${axi_ifname}_awid $awidMatch"
			set IdWidth [regexp -inline {[0-9]+} $awidMatch]
			set IdWidth [expr $IdWidth + 1]
			putdebugs $IdWidth
		}

		if {[regexp -inline -all "${axi_ifname}_awuser" $line] != "" } {
			set awuserMatch  [regexp -inline -all "[0-9]+.+${axi_ifname}_awuser" $line]	
			putdebugs "MATCH: ${axi_ifname}_awuser $awuserMatch"
			set UserWidth [regexp -inline {[0-9]+} $awuserMatch]
			set UserWidth [expr $UserWidth + 1]
			putdebugs $UserWidth
		}
		### TODO: Some protection here to make sure this procedure don't
		### 	: returns empty values
		if { $awaddrMatch != 0 } {
			#putdebugs "AXI awaddr signal not found "
		}
		if { $wdataMatch != 0 } {
			#putdebugs "AXI wdata signal not found "	
		}								
	}
			
	set axiProperties [list $addrWidth $dataWidth $IdWidth $UserWidth]	

	close $fd_wire

	return $axiProperties

}

####################################################
# Replace a matching Line in a file when it matches
# the input value
####################################################

proc updateFile {path2file match replace} {

	set tmp_file ${path2file}.tmp
	
	set fd_file [open $path2file "r"]
	set fd_tmp  [open $tmp_file  "w"]
	
	while {[gets $fd_file line] >= 0} {
	
		set newline [regsub -line "$match.*" $line $replace]
		if { $newline == "" } {
			set newline $line
		}
		puts $fd_tmp $newline	
	}

	close $fd_file
	close $fd_tmp
	
	file copy -force $tmp_file $path2file
	file delete -force $tmp_file

}

proc Add2EnvFile {path2file addString} {
	
	set fd_file [open $path2file "a"]
	
	puts $fd_file $addString
	
	close $fd_file	
}
