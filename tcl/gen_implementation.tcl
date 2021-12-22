source [pwd]/tcl/environment.tcl
source $g_root_dir/tcl/impl_utils.tcl

if { $::argc > 0 } {
 set g_root_dir $::argv
 puts "Root directory is $g_root_dir"
}

proc implementation { g_root_dir } {

	## It is assumed a dcp folder containing the synthesis dcp already exists
	file mkdir $g_root_dir/reports

	open_checkpoint $g_root_dir/dcp/synthesis.dcp
	#opt_design
	opt_design -directive Explore
	reportCriticalPaths $g_root_dir/reports/post_opt_critpath_report.csv
	
	## TODO; Check as early as possible the pinout is correct
	# report_drc -name drc_1 -ruledecks {default}
	# Extract from here the UCIO-1 message
	# "ports have no user assigned specific location"

	
	puts "Place design starting at:"
	set InitDate[ clock format [ clock seconds ] -format %d/%m/%Y ]
	set InitTime [ clock format [ clock seconds ] -format %H:%M:%S ]
	puts "$InitTime on $InitDate"
	place_design -directive Explore
	puts "Place design Finished at:"
	puts [ clock format [ clock seconds ] -format %d/%m/%Y ]
	puts [ clock format [ clock seconds ] -format %H:%M:%S ]
	puts "\(started at $InitTime on $InitDate\)"

	report_clock_utilization -file $g_root_dir/reports/clock_utilization.rpt
	
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
	 if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
	  puts "Found setup timing violations => running physical optimization"
	  #phys_opt_design -directive AggressiveExplore
	  #phys_opt_design -directive AggressiveFanoutOpt
	  #phys_opt_design -directive AddRetime
	  set CurrentDirective [lindex $PhysOptDirectives $i]
	  set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
	  phys_opt_design -directive $CurrentDirective
	  puts "\r\n-------------------------"
	  puts "Directive Applied: $CurrentDirective\r\nWNS: $CurrentSlack"
	  puts "Previous WNS: $PrevSlack"
	  set OptMsg "Directive $CurrentDirective improved WNS by [expr abs($PrevSlack - $CurrentSlack)]ns"
	  puts "$OptMsg"
	  puts $fd_opt $OptMsg
          set PrevSlack $CurrentSlack
	 } else {
	  set SkipMsg "Skipping phys_opt phase as current slack is +$CurrentSlack"
	  puts "$SkipMsg"
	  puts $fd_opt $SkipMsg
	 }
	 puts "-------------------------\r\n"
	}

	close $fd_opt
	
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

	if { [expr abs($CurrentSlack) > 1.000 ] } {
		puts "route_design will not be run as the WNS is above 1.000 "
		puts "Implementation Failed. Check the timing reports to study how to improve timing"
		## TODO: Quality of Results can be used as another criteria to not going further
	        return 0
	}

	route_design

        write_checkpoint -force $g_root_dir/dcp/implementation.dcp
		
	report_design_analysis -timing -file $g_root_dir/reports/design_analysis_timing.rpt
	report_design_analysis -complexity -file $g_root_dir/reports/design_analysis_complexity.rpt
	report_design_analysis -congestion -file $g_root_dir/reports/design_analysis_congestion.rpt
		
	report_route_status -file $g_root_dir/reports/post_route_status.rpt
	report_timing_summary -file $g_root_dir/reports/post_route_timing_summary.rpt
	report_timing_summary -delay_type min_max -report_unconstrained -warn_on_violation -check_timing_verbose -input_pins -routable_nets -file "${g_root_dir}/reports/timing_summary.rpt"
	report_timing -setup -file $g_root_dir/reports/timing_setup.rpt
	report_timing -hold -file $g_root_dir/reports/timing_hold.rpt
	report_power -file $g_root_dir/reports/post_route_power.rpt
	report_drc -file $g_root_dir/reports/post_imp_drc.rpt
	# The netlist file below can size ~220MB, need to check if it is worth
	#write_verilog -force $g_root_dir/reports/impl_netlist.v -mode timesim -sdf_anno true
	
	#write_checkpoint -force $g_root_dir/dcp/implementation.dcp 
}

	
implementation $g_root_dir 

