source [pwd]/tcl/environment.tcl
source $g_root_dir/tcl/impl_utils.tcl

if { $::argc > 0 } {
 set g_roo_dir $::argv
 puts "Root directory is $g_root_dir"
} else {
 puts "Bad usage: this script needs an argument"
 exit -1
}

# Call the exhaustivePlaceFLow procedure. The procedure itself
# creates a txt file with a summary of the exploration, and returns
# the directive that yields the most favorable WNS. Then, a file
# containing directives is edited to add it.

set bestPlaceDirective [exhaustivePlaceFlow $g_root_dir]
set directivesFile $g_root_dir/shell/directives.tcl
set fd_dve [open $directivesFile "a"]
puts $fd_dve "set g_place_directive $bestPlaceDirective"
close $fd_dve


