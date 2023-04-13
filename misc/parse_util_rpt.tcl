# Parse report, return a simple list

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