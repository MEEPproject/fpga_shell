set g_root_dir [pwd]

set g_acc_dir $g_root_dir/accelerator

file mkdir $g_root_dir/tmp
file mkdir $g_root_dir/src

source $g_root_dir/tcl/procedures.tcl
source $g_root_dir/tcl/shell_env.tcl

set g_top_file    $g_root_dir/src/system_top.sv
set g_mod_file    $g_root_dir/tmp/mod_tmp.sv
set g_inst_file   $g_root_dir/tmp/inst_tmp.sv
set g_tmp_file	  $g_root_dir/tmp/top_tmp.sv
set g_wire_file	  $g_root_dir/tmp/wire_tmp.sv
set g_shell_file	  $g_root_dir/tmp/shell_tmp.sv
set g_eamap_file  $g_root_dir/tmp/ea_top_tmp.sv
set g_acc_file	  $g_acc_dir/meep_shell/accelerator_mod.sv


set g_system_file $g_root_dir/interfaces/system.sv
set g_pcie_file   $g_root_dir/interfaces/pcie.sv
set g_ddr4_file   $g_root_dir/interfaces/ddr4.sv
set g_aurora_file $g_root_dir/interfaces/aurora.sv
set g_eth_file    $g_root_dir/interfaces/ethernet.sv
set g_uart_file   $g_root_dir/interfaces/uart.sv
set g_axi_file    $g_root_dir/interfaces/axi_intf.sv
set g_axiLi_file  $g_root_dir/interfaces/axilite_intf.sv

set g_pcie yes

# if HBM is set to no, HBMCATTRIP needs to be forced to '0'.
# There is a better option, set HBMCATTRIP as pulldown in the constraints.
# Both are valid and can live together.

set ShellInterfacesList [list g_DDR4 g_HBM g_AURORA g_ETHERNET g_BROM]


##################################################################
## Functions
##################################################################

proc ShellInterfaces { interfaceList } {

	set EnabledInft [list]
	
	putmeeps "DEBUG: [lindex $interfaceList 0]"
	
	foreach shellIntf $interfaceList {
		global $shellIntf
		if {[info exists $shellIntf]} {
			set EnabledInft [lappend EnabledInft $shellIntf]
		}
	}
	
	putmeeps "\[INFO\] Shell enabled interfaces: $EnabledInft"
	
	return $EnabledInft
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
	
	set comma ""
	

	while {[gets $fd_mod line] >= 0} {
	
	# Loof for the module name. Expecting something similar to a wrapper.
	# Use a condition to not do it in every line once it has been discovered.
		if { $moduleParsed == 0} {
		# module system_wrapper returns a single word separated by spaces
			set moduleDef [regexp -inline -all {\ymodule\y\s[a-z|A-z|0-9]*} $line]
			if { $moduleDef ne ""} {
				set moduleName [split $moduleDef " "]
				set moduleName [lindex $moduleName  1]
				set moduleName [join $moduleName]
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
				puts "INFO: Not considered branch?..."
				puts " --> $line"
				#set teclado [read stdin 1]

			}		
		}
	}
	
	puts $fd_inst "    \) ;" 
}


################################################
# This function takes the content of the interface files and unify them
# at the top of the TOP module file, meaning this is the actual I/O interface
# of the final system.
################################################

proc add_interface {g_interface g_intf_file g_mod_file} {
		
	if { $g_interface eq "yes" } {
		set fd_intf [open $g_intf_file "r"]
		set fd_mod  [open $g_mod_file  "a"]
		
		while {[gets $fd_intf line] >= 0} {
			set newline $line
			puts $fd_mod $newline
		}		
		close $fd_intf
		close $fd_mod	
	}
	
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

	while {[gets $fd_module line] >= 0} { 
		
		putmeeps "DEBUG: $axi_ifname"
		putmeeps "DEBUG: $line"
				
		if {[regexp -inline -all "${axi_ifname}_awaddr" $line] != "" } {		
			set awaddrMatch [regexp -inline -all "[0-9]+.+${axi_ifname}_awaddr" $line]
		}
		putmeeps $awaddrMatch
				
		
		if {[regexp -inline -all "${axi_ifname}_wdata" $line] != "" } {
			set wdataMatch  [regexp -inline -all "[0-9]+.+${axi_ifname}_wdata" $line]	
		}
		putmeeps $wdataMatch


		if { $awaddrMatch == "" } {
			putmeeps "AXI awaddr signal not found "
		} else {
			set addrWidth [regexp -inline  {[0-9]+[^:]} $awaddrMatch]			
		}
		if { $wdataMatch == "" } {
			putmeeps "AXI wdata signal not found "	
		} else {
			set dataWidth [regexp -inline  {[0-9]+[^:]} $wdataMatch]

		}								
	}
	set addrWidth [expr $addrWidth + 1]
	set dataWidth [expr $dataWidth + 1]

	
	set axiProperties [list $addrWidth $dataWidth]
	
	
	return $axiProperties

}

##################################################################
## Body
##################################################################

set fd_mod    [open $g_mod_file    "w"]
set fd_system [open $g_system_file "r"]


#puts $fd_mod    "module system_top"
#puts $fd_mod    "   ("

# Add the system level signals to the top level port (Clk, RST..)
fcopy $fd_system $fd_mod
close $fd_mod
close $fd_system

# 12/08/2021
# Add interface creates the TOP level I/O ports using 
# an existing template in "interfaces" folder.
# All the interfaces can be issued here as the function
# itself will look for a "yes" in the first parameter, granted
# via the sh/parse_module.sh to an environment tlc file.
# Add the enabled interfaces to the top level module.
add_interface  $g_pcie     $g_pcie_file   $g_mod_file 
add_interface  $g_DDR4     $g_ddr4_file   $g_mod_file
add_interface  $g_AURORA   $g_aurora_file $g_mod_file
add_interface  $g_ETHERNET $g_eth_file    $g_mod_file
add_interface  $g_UART     $g_uart_file   $g_mod_file
#HBM has no interfaces but hbm_cattrip

# Close the top level module
# hbm_cattrip is used to close it as it always exists
set   fd_mod  [open $g_mod_file    "a"]
puts  $fd_mod "    output        hbm_cattrip "
close $fd_mod

## Here, the module definition file has been created and closed.

# Read the top module to extract the ports and create the corresponding
# signals to make the connections between the top ports and the Shell (BD)
# Connections between the shell and the EA need are yet to be created.
# TOP LEVEL PORTS <---> Shell instance

set fd_mod  [open $g_mod_file   "r"]
set fd_inst   [open $g_inst_file    "w"]

add_instance $fd_mod $fd_inst

close $fd_mod
close $fd_inst

## Here, the shell instance is partially filled with connections 
## to the top level I/O ports.

##################################################################

# Parse the EA top module:
# The EA will be entirely connected to the MEEP Shell.
# EA ports <---> EA wires

set fd_mod   [open $g_acc_file      "r"]
set fd_inst    [open $g_eamap_file "w"]
set fd_wire   [open $g_wire_file     "w"]
set fd_shell  [open $g_shell_file     "w"]

parse_module $fd_mod $fd_inst $fd_wire $fd_shell

close $fd_mod
close $fd_inst
close $fd_wire
close $fd_shell


## Here, the EA instance has been created.

set   fd_top     [open $g_top_file   "w"]
set   fd_mod     [open $g_mod_file   "a"]
set   fd_inst    [open $g_inst_file  "r"]
set   fd_wire    [open $g_wire_file  "r"]
set   fd_shell   [open $g_shell_file "r"]

ShellInterfaces $ShellInterfacesList


#### Extract the AXI parameters needed later by the shell
set ifname "mem_axi"

#foreach $ifnamme $shellInterfaces {
	set axivalues [ get_axi_properties $fd_wire $ifname ]
#}

puts "[lindex $axivalues 0] [lindex $axivalues 1] "

##################################################################
## Next, all the temp files are put together and neceesary sintax is added.
##################################################################

puts  $fd_mod    "   ); \r\n "
fcopy $fd_wire   $fd_mod
puts  $fd_mod    "\r\n meep_shell meep_shell_inst"
puts  $fd_mod    "   \("

# Put together the Shell-top connections and the EA-shell connections
fcopy $fd_inst    $fd_mod
#fcopy $fd_map   $fd_mod
fcopy $fd_shell   $fd_mod
puts  $fd_mod    "    .hbm_cattrip             \(hbm_cattrip\)"
puts  $fd_mod 	 "\);\r\n"
close $fd_wire
close $fd_shell
#close $fd_map
close $fd_inst
close $fd_mod

set   fd_mod      [open $g_mod_file    "r"]
# Create the top module boundaries
puts  $fd_top "module system_top"
puts  $fd_top "   \("
fcopy $fd_mod     $fd_top
close $fd_mod
# close the top file now.
close $fd_top


set   fd_top      [open $g_top_file    "a"]
set   fd_acc      [open $g_eamap_file  "r"]
fcopy $fd_acc $fd_top
puts  $fd_top    "\r\nendmodule"
close $fd_acc
close $fd_top

ShellInterfaces $ShellInterfacesList

putcolors "INFO: MEEP SHELL top created" $GREEN

#file delete -force $g_root_dir/tmp

exit
