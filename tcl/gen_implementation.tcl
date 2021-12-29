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
	}


	report_methodology -file $g_root_dir/reports/post_synth_methodology.rpt

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
	reportCriticalPaths $g_root_dir/reports/post_opt_critpath_report.csv

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

	report_clock_utilization -file $g_root_dir/reports/clock_utilization.rpt
        report_methodology -file $g_root_dir/reports/post_place_methodology.rpt
	
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
	
	# Examples on how use directives
	# place_design -directive Explore
	# phys_opt_design -directive AggressiveExplore
	# phys_opt_design -directive AggressiveFanoutOpt
	# phys_opt_design -directive AddRetime
	# route_design -directive Explore
	# phys_opt_design -directive AggressiveExplore
	# route_design -tns_cleanup
	
	## set pass [expr {[get_property SLACK [get_timing_paths]] >= 0}]
	
	#set critical_nets [get_nets -of [get_timing_paths -max_paths 85]]
	#route_design -nets $critical_nets

	
	write_checkpoint -force $g_root_dir/dcp/post_place.dcp 	
	report_utilization -file $g_root_dir/reports/post_place_utilization.rpt
	report_timing_summary -file $g_root_dir/reports/post_place_timing_summary.rpt

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
        }

        report_methodology -file $g_root_dir/reports/post_route_methodology.rpt
		
	report_design_analysis -timing -file $g_root_dir/reports/design_analysis_timing.rpt
	report_design_analysis -max_paths 50 -setup -file $g_root_dir/reports/design_analysis_setup.rpt
	report_design_analysis -complexity -file $g_root_dir/reports/design_analysis_complexity.rpt
	report_design_analysis -congestion -file $g_root_dir/reports/design_analysis_congestion.rpt
		
	report_route_status -file $g_root_dir/reports/post_route_status.rpt
	report_timing_summary -file $g_root_dir/reports/post_route_timing_summary.rpt
	report_timing_summary -delay_type min_max -report_unconstrained -warn_on_violation -check_timing_verbose -input_pins -routable_nets -file ${g_root_dir}/reports/timing_summary.rpt
	report_timing -setup -file $g_root_dir/reports/timing_setup.rpt
	report_timing -hold -file $g_root_dir/reports/timing_hold.rpt
	report_power -file $g_root_dir/reports/post_route_power.rpt
	report_drc -file $g_root_dir/reports/post_route_drc.rpt
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
}


# Optionaly add a place directive as an argument.

set directivesFile $g_root_dir/shell/directives.tcl
set g_place_directive "Explore"
set g_route_directive "NoTimingRelaxation"

# SmartPlace.tcl script creates a directives file when called.

if {[file exists $directivesFile]} {
	source $directivesFile
	puts "Stored place directive $g_place_directive will be used"
}

	
implementation $g_root_dir $g_place_directive $g_route_directive

