source [pwd]/tcl/environment.tcl
source $g_root_dir/tcl/impl_utils.tcl

if { $::argc > 0 } {
 set g_project_dir $::argv
 puts "project directory is $g_project_dir"
}

open_project ${g_project_dir}/${g_project_name}.xpr

proc synthesis { g_root_dir g_number_of_jobs} {

	set number_of_jobs $g_number_of_jobs
	reset_run synth_1
	launch_runs synth_1 -jobs ${g_number_of_jobs}

	puts "Waiting for the Out Of Context IPs (Block Design) to be synthesized."
	puts "Task Started at:"
        set InitDate[ clock format [ clock seconds ] -format %d/%m/%Y ]
        set InitTime [ clock format [ clock seconds ] -format %H:%M:%S ]
        puts "$InitTime on $InitDate"

	wait_on_run synth_1
	
        puts "Finished at:"
        puts [ clock format [ clock seconds ] -format %d/%m/%Y ]
        puts [ clock format [ clock seconds ] -format %H:%M:%S ]

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
	
	## Synthesis log. The "system_top" is hardcoded as it is always the shell top 
	## module name. It could be treated as a global variable either.
	set synth_log $g_root_dir/reports/synthesis.rpt
	
	file copy -force $g_root_dir/project/system.runs/synth_1/system_top.vds $synth_log
	
	reportUnconnectedPins $synth_log 
	
	## Add this into a open-while loop to parse line by line
	#set UndrivenPins [regexp -all -inline {WARNING: [Synth 8-3295].*$} $line]
	
	
}

synthesis $g_root_dir $g_number_of_jobs
