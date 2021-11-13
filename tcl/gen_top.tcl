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
set g_map_file	  $g_root_dir/tmp/map_tmp.sv
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

##################################################################
## Functions
##################################################################

# Create EA instance using the EA top module as template. This function takes the inputs/outpus
# and uses them to create a system verilog instance using the formula ".mySignal (mySignal)"
# It also creates the wires along the way, as they will be used to connect to the Shell. The wires
# are stored in a separated file.
# It can skip blank lines and comments.
# EA ports <---> EA wires

proc parse_module {fd_mod fd_inst fd_wire} {		
	
	set firstLine 0
	
	while {[gets $fd_mod line] >= 0} {
		
		#First thing to do is to isolate "[]" so is treated as field 
		#separated with spaces
		set line [string map {\[ \ \[} $line]
		set line [string map {\] \]\ } $line]
		
        
		# Following line expects something like:
		# input [3:0] someSignal or output otherSignal
		# The string gets separated in fields "input", "[3:0]" and "someSignal"
		set fields [regexp -all -inline {\S+} $line]
		#puts [lindex $fields 1]
		set resultV  [lindex $fields 2]
		set result   [lindex $fields 1]
		set comments [lindex $fields 0]
		
		# Do the connection by default
		set doConnection 1		
		
		if { [regexp -inline -all {\/\/} $comments] ne ""} {
			#puts "// $result"			
			set doConnection 0
			#regexp: starging from the beginning of the line, find 0 or more
			#spaces before meeting the end of the line
		} elseif { [ regexp {^\s*$} $line ] } {
			set doConnection 0				
			#puts "Empty Line detected"
		} elseif { [regexp -inline -all {\[} $result] ne ""} {
			#this detects vectors, e.g [3:0] my_vector
			
			# Extract whatever falls inside "[]"
			#set debug [ regexp {\[(.*?)\]} $line]
			
			set mySignal $resultV
			set myWire "$result $resultV"
			
		} elseif { [regexp -inline -all {module} $comments] ne "" } {
			set doConnection 0
			set firstLine 1			
			puts $fd_inst "$result ${result}_inst \( "
		} elseif { [regexp -inline -all {\(} $comments] ne "" } {
			set doConnection 0
		} elseif { [regexp -inline -all {\)} $comments] ne "" } {
			set doConnection 0
		} else {		
			#puts $result
			set mySignal $result
			set myWire   $result
		}
		
		if { $doConnection eq 1 } {
			if { $firstLine eq 1} {
			set firstLine 0
			set PortConnection  "     .$mySignal     \($mySignal\)    "
			} else {
			set PortConnection  ",    .$mySignal     \($mySignal\)    "
			}
			set WireDefinition  "    wire $myWire    ;  	    	  "
			# puts "$PortConnection"
			# gets stdin ""
			puts $fd_inst $PortConnection
			puts $fd_wire $WireDefinition
			
		}
	}	
	puts $fd_inst "    \) ;" 
}


# This function takes the content of the interface files and unify them
# at the top of the TOP module file, meaning this is the actual I/O interface
# of the final system.
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


# This function creates the connections between the top level ports 
# and the MEEP Shell in the MEEP Shell instantiation. 
# The instance is closed using hbm_cattrip, which is always required,
# regardless if HBM is actually used or not.
# TOP LEVEL PORTS <---> Shell instance
proc add_instance { g_fd g_fd_tmp } {
		
	
	while {[gets $g_fd line] >= 0} {

		set fields [regexp -all -inline {\S+} $line]
		#puts [lindex $fields 1]
		set resultV  [lindex $fields 2]
		set result   [lindex $fields 1]
		set comments [lindex $fields 0]
		
		set doConnection 1
		
		if { [regexp -inline -all {//} $comments] ne ""} {
			#puts "// $result"
			set mySignal "// $result"
			set doConnection 0
		} elseif { [string match "" $line ] } {
			set doConnection 0
			#puts "Empty Line detected"
		} elseif { [regexp -inline -all {\[} $result] ne ""} {
			#this detects vectors, e.g [3:0] my_vector
			set mySignal $resultV
		} elseif { [regexp -inline -all {hbm_cattrip} $result] ne "" } {
			set doConnection 0
			# hbm_cattrip is used manually to close the instance.
		} else {		
			#puts $result
			set mySignal $result
		}
		
		if { $doConnection eq 1 } {
		set PortConnection  "    .$mySignal     \($mySignal\)    ,"
		#puts "$PortConnection"
		puts $g_fd_tmp $PortConnection
		}
	}	
}


# This function associates Peripherals and AXI interfaces.
# If the peripheral/IP has more than one interface, it will get
# marked as "yes" and the <add_acc_connection> function will go 
# over it, creating the necessary connections.
proc select_interface { g_interface } {

	set g_axi4 no
	set g_axiS no
	set g_axiL no
	set g_clk  no
	set g_uart no
	
	puts "Interface: $g_interface"

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

	#puts "$g_interface $g_axi4 $g_axiS $g_axiL $g_clk $g_uart"
	return $axi_list

}


# This function receives a peripheral/IP name, check if it exists and then create instance
# connections depending on the inferface(s) the peripheral/IP uses.
# EA ports <---> Shell instance
proc add_acc_connection { device interface ifname intf_file wire_file map_file} {


	if { $interface eq "yes" } {
		set fd_intf [open $intf_file "r"]
		set fd_map  [open $map_file  "a"]
		set fd_wire [open $wire_file "a"]		
		
		#lassign [select_interface $device] g_axi4 g_axiS g_axiL g_clk g_uart
		#Need to create a var for mathing axi ifs below
		#if g_axi4 = yes ? set match_string "axi4"

		set axiList [select_interface $device]		
	
		set matchString ""
	
		foreach item $axiList {
		#split converts  the element list into strings
		set elem [split $item " "]
		set firstElem [lindex $elem 0]
		if { $firstElem eq "yes" } {
			set matchString [lindex $elem 1]

			while {[gets $fd_intf line] >= 0} {
			#puts "Line: $line"
				if {[ string match *$matchString* $line ] } {
					#puts "MATCH! $matchString"
					set newline [regsub $matchString $line $ifname ]								
					puts $fd_map "    .$newline    ($newline)    , "
					#puts "    .$newline    ($newline)    , "
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


# This function creates simple connections in the Shell instance. The signal
# is passed as a parameter and then added.
# EA ports <---> Shell instance
proc add_simple_connection { name map_file wire_file} {

	set fd_map   [open $map_file "a"]
	set fd_wire  [open $wire_file "a"]
	puts $fd_map  "    .$name        ($name)    , "
	#puts $fd_wire "    wire    $name    ;     " 
	close $fd_map
	close $fd_wire

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
# Add interface creates the top level signals using 
# an existing template in "interfaces" folder.
# All the interfaces can be issued here as the function
# itself will look for a "yes" in the first parameter.
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

set fd_mod    [open $g_mod_file    "r"]
set fd_inst   [open $g_inst_file   "w"]

add_instance $fd_mod $fd_inst

close $fd_mod
close $fd_inst

## Here, the shell instantiation is partially filled with connections 
## to the top level ports.

##################################################################

# Parse the EA top module:
# The EA will be entirely connected to the MEEP Shell.
# EA ports <---> EA wires

set fd_mod    [open $g_acc_file    "r"]
set fd_inst   [open $g_eamap_file  "w"]
set fd_wire   [open $g_wire_file   "w"]

parse_module $fd_mod $fd_inst $fd_wire

close $fd_mod
close $fd_inst
close $fd_wire

## Here, the EA instance has been created.

##################################################################
# Create AXI-based connections. It follows an AXI4 template from "interfaces" folder,
# and detects the same in the EA via <add_acc_connection>.
# Simple connection will be created also using <add_simple_connection>
# EA ports <---> Shell instance
##################################################################

if { $g_DDR4 eq "yes"} {
	# Create the connections between the EA and the Shell
	add_acc_connection "DDR4" $g_DDR4 $g_DDR4_ifname $g_axi_file $g_wire_file $g_map_file
} elseif { $g_HBM eq "yes"} {
	# Create the connections between the EA and the Shell
	add_acc_connection "HBM" $g_HBM $g_HBM_ifname $g_axi_file $g_wire_file $g_map_file
}


# Create not-AXI connections
if {[info exists g_CLK0]} {
	add_simple_connection $g_CLK0 $g_map_file $g_wire_file
}
if {[info exists g_RST0]} {
	add_simple_connection $g_RST0 $g_map_file $g_wire_file
}
if {[info exists g_UART_MODE]} {
	# TODO: Add here if mode eq simple or full
	add_acc_connection "UART" "yes" $g_UART_ifname $g_axiLi_file $g_wire_file $g_map_file
	if {[info exists g_UART_irq]} {
		add_simple_connection $g_UART_irq $g_map_file $g_wire_file
	}
}
#TODO: add_simple_connection should go through a list of interfaces (foreach)

set   fd_top      [open $g_top_file    "w"]
set   fd_mod      [open $g_mod_file    "a"]
set   fd_inst     [open $g_inst_file   "r"]
set   fd_map      [open $g_map_file    "r"]
set   fd_wire     [open $g_wire_file   "r"]

##################################################################
## Next, all the temp files are put together and neceesary sintax is added.
##################################################################

puts  $fd_mod    "   ); \r\n "
fcopy $fd_wire   $fd_mod
puts  $fd_mod    "\r\n meep_shell meep_shell_inst"
puts  $fd_mod    "   \("

# Put together the Shell-top connections and the EA-shell connections
fcopy $fd_inst    $fd_mod
fcopy $fd_map     $fd_mod
puts  $fd_mod    "    .hbm_cattrip             \(hbm_cattrip\)"
puts  $fd_mod 	 "\);\r\n"
close $fd_wire
close $fd_map
close $fd_inst
close $fd_mod

# Create the top module boundaries
puts  $fd_top "module system_top"
puts  $fd_top "   \("
set   fd_mod      [open $g_mod_file    "r"]
fcopy $fd_mod     $fd_top
close $fd_mod
close $fd_top


set   fd_top      [open $g_top_file    "a"]
set   fd_acc      [open $g_eamap_file  "r"]
fcopy $fd_acc $fd_top
puts  $fd_top    "\r\nendmodule"
close $fd_acc
close $fd_top

putcolors "INFO: MEEP SHELL top created" $GREEN

file delete -force $g_root_dir/tmp

exit
