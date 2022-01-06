source [pwd]/tcl/environment.tcl
source $g_root_dir/tcl/impl_utils.tcl

if { $::argc > 0 } {
 set g_root_dir $::argv
 puts "Root directory is $g_root_dir"
}

proc implementation { g_root_dir g_place_directive g_route_directive} {

	set RefTime [clock seconds]
	## It is assumed a dcp folder containing the synthesis dcp already exists
	file mkdir $g_root_dir/reports

	open_checkpoint $g_root_dir/dcp/synthesis.dcp

	### Check as early as possible that all logical ports and all I/O
	### standards are specified.
	### This likely shouldn't happen as the Shell is "fixed", but it is
	### better to detect if that happen here than in the bitgen phase.
	if { [reportEarlyDRC $g_root_dir] == 1 } {
		puts "Detected Unspecified Logic Levels or Unconstraiend ports."
		puts "Implementation will not continue. Check the pinout."
		# TODO: Check if this is working commenting a physical top level pin
	}



	#opt_design
	# opt_design can be called with switches: opt_design -retarget -sweep
	# For example, a congested design may benefit from skipping the remap option.
	# By default, opt_design does: -retarget -sweep -remap -propconst -resynth_area
	# Non-default: -area_mode -effort_level <arg>  -verbose
	opt_design -directive Explore

	# Store the Lapsed time up to opt_desing finish
	set Lapsed2optTime [getLapsedTime $RefTime]
	puts "Lapsed time after opt_design: $Lapsed2optTime"
	puts "--------------------------------------"

        write_checkpoint -force $g_root_dir/dcp/post_opt.dcp

	# Optional Power Optimization
	#power_opt_design	
	# TODO: Add a time stamp from here to the end of the process, so it can be compared
	# with other configurations -Vivado flow or when the place directive is set after
	# getting it with ExhaustivePlaceFlow
	
	puts "Place design starting at:"
	set InitDate [ clock format [ clock seconds ] -format %d/%m/%Y ]
	set InitTime [ clock format [ clock seconds ] -format %H:%M:%S ]
	puts "$InitTime on $InitDate"
	place_design -directive $g_place_directive

	set Lapsed2placeTime [getLapsedTime $RefTime] 
	puts "Lapsed time after place_design: $Lapsed2placeTime"
        puts "--------------------------------------"

	puts "------------------------"
	puts "Place design Finished at:"
	puts [ clock format [ clock seconds ] -format %d/%m/%Y ]
	puts [ clock format [ clock seconds ] -format %H:%M:%S ]
	puts "\(started at $InitTime on $InitDate\)"
	puts "Directive used: $g_place_directive"
	puts "------------------------"

	# Optionally run optimization if there are timing violations after placement
	
	set PhysOptDirectives "Explore \
        ExploreWithHoldFix  \
        AggressiveExplore  \
        AlternateReplication  \
        AggressiveFanoutOpt \
        AddRetime \
        AlternateFlowWithRetiming \
        RuntimeOptimized \
        ExploreWithAggressiveHoldFix \
        RQS \
        Default"
	set fd_opt [open $g_root_dir/reports/opt_strategies.rpt "w"] 

	set i 0
	set nloops 8 
	set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
	set PrevSlack $CurrentSlack

	for {set i 0} {$i < $nloops} {incr i} {		

	 set CurrentDirective [lindex $PhysOptDirectives $i]

	 if { [expr $CurrentSlack < 0] } {
	  puts "Found setup timing violations => running physical optimization"
	  phys_opt_design -directive $CurrentDirective
	  # Get the Slack after the optimization
	  set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
	  puts "\r\n-------------------------"
	  set Msg0 "Directive Applied: $CurrentDirective\r\nWNS: $CurrentSlack\r\nPrevious WNS: $PrevSlack"
	  puts $Msg0
	  puts $fd_opt $Msg0
	  set OptMsg "Directive $CurrentDirective improved WNS by [expr abs($PrevSlack - $CurrentSlack)]ns"
	  puts "$OptMsg"
	  puts $fd_opt $OptMsg
          set PrevSlack $CurrentSlack
	 } else {
	  set SkipMsg "Skipping phys_opt phase \($CurrentDirective\) as current slack is +${CurrentSlack}ns"
	  puts "$SkipMsg"
	  puts $fd_opt $SkipMsg
	 }
	 puts "-------------------------\r\n"
	}

	close $fd_opt

	set Lapsed2physOptTime [getLapsedTime $RefTime]
	puts "Lapsed time after phys_opt_design: $Lapsed2physOptTime"
        puts "--------------------------------------"
	
	#set critical_nets [get_nets -of [get_timing_paths -max_paths 85]]
	#route_design -nets $critical_nets

	write_checkpoint -force $g_root_dir/dcp/post_place.dcp 	

	if { [expr $CurrentSlack < -1.000 ] } {
		puts "route_design will not be run as the WNS is above 1.000 "
		puts "Implementation Failed. Check the timing reports to study how to improve timing"
		## TODO: Quality of Results can be used as another criteria to not going further
	        return 0	
	}	

	# TODO: Explore other routing strategies?
	route_design -directive $g_route_directive

	set Lapsed2routeTime [getLapsedTime $RefTime]
	puts "Lapsed time after route_design: $Lapsed2routeTime"
        puts "--------------------------------------"

        write_checkpoint -force $g_root_dir/dcp/implementation.dcp
	## TODO: Directives can be added here to go the extra mile. E.g, the WNS is below -0.1 after 
	## default routing
        set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]

	if { [expr $CurrentSlack < 0.000] && [expr $CurrentSlack > -0.200] } {
                phys_opt_design -directive AggressiveExplore
	        write_checkpoint -force $g_root_dir/dcp/implementation.dcp
	        set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
        }

	# The netlist file below can size ~220MB, need to check if it is worth
	#write_verilog -force $g_root_dir/reports/impl_netlist.v -mode timesim -sdf_anno true
	# TODO: Create a filter to write only the VIOLATED nets
	set Lapsed2ImplTime [getLapsedTime $RefTime]
	puts "Lapsed Implementation time: $Lapsed2ImplTime"
        puts "--------------------------------------"

	####### The following lines are used to store the more relevant desingn parameters into a file ###
	# Lapsed time for all steps
	# Directives used
	# WNS, TNS
	# Failing paths, if they exist
	# More?
	
        set fd_sum [open $g_root_dir/reports/summary.rpt "w"]

	puts $fd_sum "======================================="
	puts $fd_sum "== FPGA Shell implementation summary =="
        puts $fd_sum "======================================="
	puts $fd_sum "\r\n"
	puts $fd_sum "1. Timing"

        if { [expr $CurrentSlack < 0.000] } { 

	  puts $fd_sum "* Timing constraints are not met"
	  set WorstTimingPath [get_timing_paths -max_paths 1 -nworst 1 -setup]
	  puts $fd_sum "Critical Path:\r\n$WorstTimingPath\r\n"

	} else {
          puts $fd_sum "* The design closed timing"
	}

        puts $fd_sum "Design WNS=${CurrentSlack}ns"

	puts $fd_sum "2. Directives"
        puts $fd_sum "* Place Directive used: $g_place_directive"
        puts $fd_sum "* Route Directive used: $g_route_directive"
        puts $fd_sum "3. Lapsed timestamps to reach stages"
        puts $fd_sum "* Post synthesis optimization @ $Lapsed2optTime"
	puts $fd_sum "* Post place                  @ $Lapsed2placeTime"
        puts $fd_sum "* Post place optimization     @ $Lapsed2physOptTime"
        puts $fd_sum "* Post route                  @ $Lapsed2routeTime"
        puts $fd_sum "* Post route Opt              @ $Lapsed2ImplTime"

	close $fd_sum
}


# Optionaly add a place directive as an argument.

set directivesFile $g_root_dir/shell/directives.tcl
set g_place_directive "ExtraNetDelay_low"
set g_route_directive "NoTimingRelaxation"

# SmartPlace.tcl script creates a directives file when called.

if {[file exists $directivesFile]} {
	source $directivesFile
	puts "Stored place directive $g_place_directive will be used"
}

	
implementation $g_root_dir $g_place_directive $g_route_directive

