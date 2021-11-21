set meep_dir [ pwd ]

source $meep_dir/tcl/shell_env.tcl


if { [info exists g_BROM] } {
	set initBromFile "bootrom.mem"
	set initFilePath $meep_dir/binaries/$initBromFile
	#This needs to be extracted from the definition file, not set here would be needed
	if { [file exists $initFilePath] == 1} {               
        file copy -force $initFilePath $meep_dir/ip/axi_brom/src/$initBromFile
        puts " BROM init file copied!"
    } else {
	    puts " BROM init file hasn't been provided!"
		puts " Consider to create it under EA/$initFilePath folder \r\n"
		#puts " Defaults to "
		#file copy -force $initFilePath $meep_dir/accelerator/meep_shell/binaries/$initBromFile
	}
	source $meep_dir/ip/axi_brom/tcl/gen_project.tcl
	}