source [pwd]/tcl/environment.tcl

if { $::argc > 0 } {
 set g_root_dir $::argv
 puts "Root directory is $g_root_dir"
}

proc implementation { g_root_dir } {

	## It is assumed a dcp folder containing the synthesis dcp already exists
	file mkdir $g_root_dir/reports

	open_checkpoint $g_root_dir/dcp/synthesis.dcp
	opt_design
	#opt_design -directive Explore
	reportCriticalPaths $g_root_dir/reports/post_opt_critpath_report.csv
	
	puts "Place design starting at:"
	puts [ clock format [ clock seconds ] -format %m%d%Y ]
	puts [ clock format [ clock seconds ] -format %H%M%S ]
	place_design
	puts "Place design Finished at:"
	puts [ clock format [ clock seconds ] -format %m%d%Y ]
	puts [ clock format [ clock seconds ] -format %H%M%S ]

	report_clock_utilization -file $g_root_dir/reports/clock_util.rpt
	
	# Optionally run optimization if there are timing violations after placement
	if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
	 puts "Found setup timing violations => running physical optimization"
	phys_opt_design
	}
	
	# Examples on how use directives
	# place_design -directive Explore
	# phys_opt_design -directive AggressiveExplore
	# phys_opt_design -directive AggressiveFanoutOpt
	# phys_opt_design -directive AlternateReplication
	# route_design -directive Explore
	# phys_opt_design -directive AggressiveExplore
	# route_design -tns_cleanup
	
	## set pass [expr {[get_property SLACK [get_timing_paths]] >= 0}]

	
	write_checkpoint -force $g_root_dir/dcp/post_place.dcp 	
	report_utilization -file $g_root_dir/reports/post_place_util.rpt
	report_timing_summary -file $g_root_dir/reports/post_place_timing_summary.rpt

	route_design
		
	report_design_analysis -timing
	report_design_analysis -complexity
	report_design_analysis -congestion
		
	report_route_status -file $g_root_dir/reports/post_route_status.rpt
	report_timing_summary -file $g_root_dir/reports/post_route_timing_summary.rpt
	report_timing_summary -delay_type min_max -report_unconstrained -warn_on_violation -check_timing_verbose -input_pins -routable_nets -file "${g_root_dir}/reports/timing_summary.rpt"
	report_timing -setup -file $g_root_dir/reports/timing_setup.rpt
	report_timing -hold -file $g_root_dir/reports/timing_hold.rpt
	report_power -file $g_root_dir/reports/post_route_power.rpt
	report_drc -file $g_root_dir/reports/post_imp_drc.rpt
	write_verilog -force $g_root_dir/reports/impl_netlist.v -mode timesim -sdf_anno true
	
	write_checkpoint -force $g_root_dir/dcp/implementation.dcp 
}

	
implementation $g_root_dir 

