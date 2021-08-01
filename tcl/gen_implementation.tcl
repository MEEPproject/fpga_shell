source [pwd]/tcl/environment.tcl

if { $::argc > 0 } {
 set g_project_dir $::argv
 puts "project directory is $g_project_dir"
}

open_project ${g_project_dir}/${g_project_name}.xpr

proc reportImpl {g_root_dir g_project_dir g_project_name} {

	set runmefile "${g_project_dir}/${g_project_name}.runs/impl_1/runme.log"

	open_run impl_1
	file delete -force $g_root_dir/reports
	file mkdir $g_root_dir/reports
	file mkdir $g_root_dir/dcp
	write_checkpoint -force $g_root_dir/dcp/implementation.dcp 
	report_clocks -file "${g_root_dir}/reports/clock.rpt"
	report_utilization -file "${g_root_dir}/reports/utilization.rpt"
	report_timing_summary -delay_type min_max -report_unconstrained -warn_on_violation -check_timing_verbose -input_pins -routable_nets -file "${g_root_dir}/reports/timing_summary.rpt"
	report_power -file "${g_root_dir}/reports/power.rpt"
	report_drc -file "${g_root_dir}/reports/drc_imp.rpt"
	report_timing -setup -file "${g_root_dir}/reports/timing_setup.rpt"
	report_timing -hold -file "${g_root_dir}/reports/timing_hold.rpt"
	file copy -force -- $runmefile "${g_root_dir}/reports/implementation.log"
}

proc implementation { g_root_dir g_project_name g_project_dir g_number_of_jobs} {

	set number_of_jobs $g_number_of_jobs
	reset_run impl_1
	launch_runs impl_1 -jobs ${number_of_jobs}
	wait_on_run impl_1
	reportImpl $g_root_dir $g_project_dir $g_project_name
}

implementation $g_root_dir $g_project_name $g_project_dir $g_number_of_jobs

