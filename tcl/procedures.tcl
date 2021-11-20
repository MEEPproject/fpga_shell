set RED "\033\[1;31m"
set GREEN "\033\[1;32m"
set YELLOW "\033\[1;33m"
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

	puts "${RED}\[MEEP\]\ \[ERROR\]: ${RESET}${someText}"
	
	return 1
}

proc putwarnings { someText } {

	set YELLOW "\033\[1;33m"
	set RESET "\033\[0m"

	puts "${YELLOW}\[MEEP\]\ \[WARNING\]: ${RESET}${someText}"
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
	
	# Loof for the module name. Expecting something similar to a wrapper.
	# Use a condition to not do it in every line once it has been discovered.
		if { $moduleParsed == 0} {
		# module system_wrapper returns a single word separated by spaces
			set moduleDef [regexp -inline -all {\ymodule\y\s[a-z|A-z|0-9]*} $line]
			if { $moduleDef ne ""} {
			
				set moduleName [join $moduleDef]
				set moduleName [split $moduleName " "]
				set moduleName [lindex $moduleName  1]
				set moduleParsed 1
				puts $fd_inst "$moduleName ${moduleName}_inst \( "
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
				set ret [puterros "Not considered branch?...--> $line"]
				#set teclado [read stdin 1]

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
			puts "INFO: skipping hbm_cattrip port\r\n"
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
# This function associates Peripherals and AXI interfaces.
# If the peripheral/IP has more than one interface, it will get
# marked as "yes" and the <add_acc_connection> function will go 
# over it, creating the necessary connections.
########################################################
proc select_interface { g_interface } {

	set g_axi4 no
	set g_axiS no
	set g_axiL no
	set g_clk  no
	set g_uart no
	
	putmeeps "Interface: $g_interface"

	switch -regexp $g_interface {
		"DDR4" {
			set g_axi4 yes
		}
		"HBM" {
			set g_axi4 yes
		}
		"ETHERNET" {
			set g_axi4 yes
			set g_axiS yes
			set g_axiL yes
		}
		"AURORA" {
			set g_axiS yes
		}
		[CLK0,CLK1,CLK2,CLK3] {
			set g_clk yes
		}
		"UART" {
			set g_uart yes
			#if mode is not simple:
			set g_axiL yes
		}
		default {
			set g_axi4 no
			set g_axiS no
			set g_axiL no
			set g_clk  no
			set g_uart no
		}
	}
	
	set axi_list "{$g_axi4 axi4} {$g_axiS axiS} {$g_axiL axiL} {$g_clk clk} {$g_uart rs232}"

	# This labels (axi4, axiS..) need to match what is used in the corresponding interface file present 
	# in the "$root_dir/interface" folder. 

	#putmeeps "$g_interface $g_axi4 $g_axiS $g_axiL $g_clk $g_uart"
	return $axi_list

}

########################################################
# This function receives a peripheral/IP name, check if it exists and then create instance
# connections depending on the inferface(s) the peripheral/IP uses.
# EA ports <---> Shell instance
########################################################
proc add_acc_connection { device interface ifname intf_file wire_file map_file} {

	if { $interface eq "yes" } {
		set fd_intf    [open $intf_file "r"]
		set fd_map  [open $map_file  "a"]
		set fd_wire  [open $wire_file "a"]		
		
		#lassign [select_interface $device] g_axi4 g_axiS g_axiL g_clk g_uart
		#Need to create a var for mathing axi ifs below
		#if g_axi4 = yes ? set match_string "axi4"

		# This send an interface (e.g, ETHERNET) and get the list of interfaces needed
		# to implement it. It can happen Ethernet needs not only AXI4 but also 
		# AXILite or AXI Stream.
		set axiList [select_interface $device]		
	
		set matchString ""
	
		# e.g AXI4
		foreach item $axiList {
		#split converts  the element list into strings
			set elem [split $item " "]
			set firstElem [lindex $elem 0]
			
			# The first element is Yes or NO (2D list). 
			# TODO: Refactor. 
			if { $firstElem eq "yes" } {
			
				set matchString [lindex $elem 1]

				while {[gets $fd_intf line] >= 0} {
				#putmeeps "Line: $line"
					if {[ string match *$matchString* $line ] } {
						#putmeeps "MATCH! $matchString"
						set newline [regsub $matchString $line $ifname ]								
						puts $fd_map "    .$newline    ($newline)    , "
						#putmeeps "    .$newline    ($newline)    , "
						#gets stdin ""
					}
				}	
			}	
		}	
		close $fd_intf
		close $fd_map	
		close $fd_wire
	}	
}


########################################################
# This procedure receives the EA module name and 
# extracts address and data bus widths.
# TODO: This procedure counts on the vector to be declared
#     : always using '0' as the righmost value e.g 63:0
########################################################
proc get_axi_properties { fd_module axi_ifname } {

	set awaddrMatch 0
	set wdataMatch  0
	set axiProperties [list]
	set addrWidth 0
	set dataWidth 0
	set IdWidth 0

	
	putmeeps "Inside properties: $axi_ifname"

	while {[gets $fd_module line] >= 0} { 
		
				
		if {[regexp -inline -all "${axi_ifname}_awaddr" $line] != "" } {		
			set awaddrMatch [regexp -inline -all "[0-9]+.+${axi_ifname}_awaddr" $line]
			putmeeps "MATCH: ${axi_ifname}_awaddr $awaddrMatch"
			set addrWidth [regexp -inline  {[0-9]+[^:]} $awaddrMatch]			
			set addrWidth [expr $addrWidth + 1]
			putmeeps $addrWidth

		}
						
		if {[regexp -inline -all "${axi_ifname}_wdata" $line] != "" } {
			set wdataMatch  [regexp -inline -all "[0-9]+.+${axi_ifname}_wdata" $line]	
			putmeeps "MATCH: ${axi_ifname}_wdata $wdataMatch"
			set dataWidth [regexp -inline  {[0-9]+[^:]} $wdataMatch]
			set dataWidth [expr $dataWidth + 1]
			putmeeps $dataWidth
		}
		
		if {[regexp -inline -all "${axi_ifname}_awid" $line] != "" } {
			set awidMatch  [regexp -inline -all "[0-9]+.+${axi_ifname}_awid" $line]	
			putmeeps "MATCH: ${axi_ifname}_awid $awidMatch"
			set IdWidth [regexp -inline {[0-9]+(?=:)} $awidMatch]
			set IdWidth [expr $IdWidth + 1]
			putmeeps $IdWidth
		}
		
		if { $awaddrMatch != 0 } {
			#putmeeps "AXI awaddr signal not found "
		}
		if { $wdataMatch != 0 } {
			#putmeeps "AXI wdata signal not found "	
		}								
	}
			
	set axiProperties [list $addrWidth $dataWidth $IdWidth]	
	
	return $axiProperties

}

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
