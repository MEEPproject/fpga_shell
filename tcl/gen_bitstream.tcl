source [pwd]/tcl/environment.tcl

if { $::argc > 0 } {
 set g_roo_dir $::argv
 puts "Root directory is $g_root_dir"
} else {
 puts "Bad usage: this script needs an argument"
 exit -1
}


proc bitstream { g_root_dir } {

	file mkdir $g_root_dir/bitstream
	open_checkpoint $g_root_dir/dcp/implementation.dcp
	write_bitstream -force ${g_root_dir}/bitstream/system.bit
}

bitstream $g_root_dir

