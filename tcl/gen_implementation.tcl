source [pwd]/tcl/environment.tcl

if { $::argc > 0 } {
 set g_project_dir $::argv
 puts "project directory is $g_project_dir"
}

proc implementation { g_root_dir } {

	open_checkpoint $g_root_dir/dcp/synthesis.dcp
	opt_design
	place_design
	route_design
	
	file mkdir $g_root_dir/dcp
	write_checkpoint -force $g_root_dir/dcp/implementation.dcp 
}

proc reportImpl { g_root_dir } {


	file delete -force $g_root_dir/reports
	file mkdir $g_root_dir/reports

	report_clocks -file "${g_root_dir}/reports/clock.rpt"
	report_utilization -file "${g_root_dir}/reports/utilization.rpt"
	report_timing_summary -delay_type min_max -report_unconstrained -warn_on_violation -check_timing_verbose -input_pins -routable_nets -file "${g_root_dir}/reports/timing_summary.rpt"
	report_power -file "${g_root_dir}/reports/power.rpt"
	report_drc -file "${g_root_dir}/reports/drc_imp.rpt"
	report_timing -setup -file "${g_root_dir}/reports/timing_setup.rpt"
	report_timing -hold -file "${g_root_dir}/reports/timing_hold.rpt"
}
	
implementation $g_root_dir 
reportImpl $g_root_dir

