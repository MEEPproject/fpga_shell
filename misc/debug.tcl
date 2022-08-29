set attributes "\(* keep=\"TRUE\" *\) \(* mark_debug=\"TRUE\" *\) reg " 
set clkProcess "always @\(posedge clk\) begin : p_debug"
set header     "// ---------------- Debug Section ------------------- "

set thisDir [pwd]

set g_sig_file "$thisDir/signal_list.txt"
set g_deb_file "$thisDir/debug_out.txt"

set fd_in   [open $g_sig_file "r"]
set fd_out  [open $g_deb_file "w"]

puts $fd_out $header

set SignalList [list]

while {[gets $fd_in line] >= 0} {

	if { [regexp -inline -all {^\s*//} $line] ne ""} {
	#putmeeps "INFO: comment line\r\n"	
	# Detect empty lines
	} elseif { [ regexp {^\s*$} $line ] } {
	#putmeeps "INFO: empty line\r\n"
	} else {
	
	set line [string map {\[ \ \[} $line]
	set line [string map {\] \]\ } $line]
				
	# Join is used to remove the regexp returning braces. They are placed there
	# by tcl to not to interpted returning brackets.
			
	set MyVector [regexp -all -inline {\[.+\]} $line]
	set MyVector [string map {" " ""} $MyVector]
	set MyVector [join $MyVector]

	# Add a heading space to prepare the next regexp
	set space " "
	set line ${space}${line}
	set MySignal [regexp -inline -all {\s{1}[a-z|A-Z|0-9|-|_]+\s*,*$} $line]
	set MySignal [string map {" " ""} $MySignal]
	# Need to remove the comma, as there is no lookbehind regex in tcl
	set MySignal [string map {"," ""} $MySignal]
	set MySignal [join $MySignal]

	set reg_signal "$MyVector ${MySignal}_r;"
	
	set SignalList [lappend SignalList $MySignal]

	puts $fd_out "$attributes $reg_signal"
	}
}

close $fd_in

puts $fd_out "\r\n$clkProcess\r\n"

foreach Member $SignalList {
	
	set reg_signal ${Member}_r

	puts $fd_out "    $reg_signal <= $Member;"

}

puts $fd_out "\r\nend\r\n"

close $fd_out
