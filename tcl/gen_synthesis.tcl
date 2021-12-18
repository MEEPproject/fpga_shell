source [pwd]/tcl/environment.tcl

if { $::argc > 0 } {
 set g_project_dir $::argv
 puts "project directory is $g_project_dir"
}

open_project ${g_project_dir}/${g_project_name}.xpr

proc synthesis { g_root_dir g_number_of_jobs} {

	set number_of_jobs $g_number_of_jobs
	reset_run synth_1
	launch_runs synth_1 -jobs ${g_number_of_jobs}
	puts "Waiting for the Out Of Context IPs to be synthesized..."
	wait_on_run synth_1
	open_run synth_1

	set status [get_property STATUS [get_runs synth_1]]

	puts "$status"

	if { $status != "synth_design Complete!"} {	
		puts "Design synthesis failed, exiting ..."
		exit 1
	}
	
	file mkdir $g_root_dir/dcp
	file mkdir $g_root_dir/reports



	write_checkpoint -force $g_root_dir/dcp/synthesis.dcp
	report_timing_summary -file $g_root_dir/reports/post_synth_timing_summary.rpt
	report_utilization -file $g_root_dir/reports/post_synth_util.rpt
	
	# Run custom script to report critical timing paths
	reportCriticalPaths $g_root_dir/reports/post_synth_critpath_report.csv
	
	## Synthesis log
	file copy $g_project_dir/system.runs/synth_1/system.vds $g_root_dir/reports/synthesis.rpt
	
	## Add this into a open-while loop to parse line by line
	#set UndrivenPins [regexp -all -inline {WARNING: [Synth 8-3295].*$} $line]
	
	
}

synthesis $g_root_dir $g_number_of_jobs
