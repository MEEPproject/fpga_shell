# Parse report, return a simple list


if { $::argc > 0 } {
    set g_file_path $::argv
    puts "File path is $g_file_path"
} else {
    puts "Bad usage: this script needs an argument"
    exit -1
}

proc ParseReport { FilePath } {

    set fd     [open $FilePath "r"]

    set SkipNextLine 4; # Random number above 2

    while {[gets $fd line] >= 0} {

        # Remove white spaces, find the separator and use semicolons instead
        set line [string map {" " ""} $line]
        set line [string map {"\t" ""} $line]	
        
        set fields [split $line "|"]

        # Semicolons are regsub friendly. Remove the leading and trailing sc.
        set line [string map {"|" ","} $line]
        set line [regsub {^,} $line "" ]
        set line [regsub {,$} $line "" ]

        incr SkipNextLine

        if { [lindex $fields 1] == "Instance" } {
            set Resources $line
            set SkipNextLine 0
        }

        if { $SkipNextLine == 2} {
            set Values $line   
        }        

    }

    # Remove the first two fields, non relevant for the DataBase
    # Then, add semicolons, which makes the returning values a CSV list, python will be happy.
    set Resources [split $Resources ","]
    set Resources [lrange $Resources 2 end]
    set Resources [join $Resources ","]

    set Values [split $Values ","]
    set Values [lrange $Values 2 end]
    set Values [join $Values ","]


    return [list $Resources $Values]
}

if {[file exists $g_file_path]} {
    set ParsedUtilizaion [ParseReport $g_file_path]
    set tmp_file ${g_file_path}.csv
    set fd_tmp  [open $tmp_file  "w"]
    puts $fd_tmp [lindex $ParsedUtilizaion 0]
    puts $fd_tmp [lindex $ParsedUtilizaion 1]
    close $fd_tmp

} else {
    puts "Report File doesn't exist"
    # $g_root_dir/reports/post_route/utilization_hier.rpt
}

