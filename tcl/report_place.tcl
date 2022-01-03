source [pwd]/tcl/environment.tcl

if { $::argc > 0 } {
 set g_roo_dir $::argv
 puts "Root directory is $g_root_dir"
} else {
 puts "Bad usage: this script needs an argument"
 exit -1
}


proc reportPlace{ g_root_dir } {

	set postPlaceDir $g_root_dir/reports/post_place

	file mkdir $postPlaceDir
	open_checkpoint $g_root_dir/dcp/post_place.dcp
        report_clock_utilization -file $postPlaceDir/clock_utilization.rpt
	report_methodology -file $postPlaceDir/methodology.rpt
	report_utilization -hierarchical -file $postPlaceDir/utilization_hier.rpt
	report_utilization -file $postPlaceDir/utilization_summary.rpt
        report_utilization -slr -file $postPlaceDir/utilization_slr.rpt
	report_timing_summary -file $postPlaceDir/timing_summary.rpt
        reportCriticalPaths $postPlaceDir/critical_path_report.csv
}


reportPlace $g_root_dir

