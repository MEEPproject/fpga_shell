source [pwd]/tcl/environment.tcl

if { $::argc > 0 } {
 set g_project_dir $::argv
 puts "project directory is $g_project_dir"
}


proc bitstream { g_root_dir g_project_name g_project_dir } {

	open_checkpoint $g_root_dir/dcp/implementation.dcp
	write_bitstream -force ${g_root_dir}/${g_project_name}.bit
}

bitstream $g_root_dir $g_project_name $g_project_dir 

