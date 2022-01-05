source [pwd]/tcl/environment.tcl
source $g_root_dir/tcl/impl_utils.tcl

if { $::argc > 0 } {
 set g_root_dir $::argv
 puts "Root directory is $g_root_dir"
} else {
 puts "Bad usage: this script needs an argument"
 exit -1
}


proc reportSynth { g_root_dir } {

	set synthDir $g_root_dir/reports/synthesis

	file mkdir $synthDir
	open_checkpoint $g_root_dir/dcp/synthesis.dcp
	report_methodology -file $synthDir/methodology.rpt
	report_utilization -hierarchical -file $synthDir/utilization_hier.rpt
        report_timing_summary -file $synthDir/timing_summary.rpt
	reportCriticalPaths $synthDir/critical_path_report.csv
	# TODO: Add any other report that could be useful at this stage

}

reportSynth $g_root_dir

