#------------------------------------------------------------------------
# reportUnconnectedPins
#------------------------------------------------------------------------
# Summarizes the Vivado log section where it is shown what pins are 
# unconnected/grounded, which is usually an error.
#------------------------------------------------------------------------
proc reportUnconnectedPins { SynthLogFile } {

	#TODO: it must exists, catch error otherwise
	global g_root_dir
	
	set reportFile $g_root_dir/reports/unconnectedPins.rpt

	## Synthesis log
	set fd_synth  [open $SynthLogFile r]
	set fd_report [open $reportFile w  ]

	set UndrivenPinDetected 0

	while {[gets $fd_synth line] >= 0} {
		
		set UndrivenPins [regexp -all -inline {WARNING: \[Synth 8-3295\].*$} $line]
		puts $fd_report $UndrivenPins
		puts "$UndrivenPins"
		if { $UndrivenPins != ""} {
			set UndrivenPinDetected 1
		}	
	}

	if { $UndrivenPinDetected == 0 } {
		set OKMsg "No undriven pins were detected"
		puts $OKMsg
		puts $fd_report $OKMsg		
	}	
	
	close $fd_synth
	close $fd_report

}

#------------------------------------------------------------------------
# reportEarlyDRC
#------------------------------------------------------------------------
# Check as early as possible that all logical ports and all I/O
# standards are specified.
# This likely shouldn't happen as the Shell is "fixed", but it is
# better to detect if that happen here than in the bitgen phase.
#------------------------------------------------------------------------

proc reportEarlyDRC { root_dir } {

	set g_root_dir $root_dir

        set drc_early_rpt $g_root_dir/reports/drc_early.rpt

        report_drc -name drc_1 -ruledecks {default} -file $drc_early_rpt

        set fd_drc [open $drc_early_rpt "r"]

	set UnconstrainedPortMsg "Unconstrained Logical Port"
        set UnspecifiedStdMsg  "Unspecified I/O Standard"

	set Error 0
	set UnconstrainedPort ""
	set UnspecifiedStd ""

        while {[gets $fd_drc line] >= 0} {

                set UnconstrainedPort [regexp -all -inline "${UnconstrainedPortMsg}.*[1-9]+" $line]
                set UnspecifiedStd    [regexp -all -inline "${UnspecifiedStdMsg}.*[1-9+]" $line]

                if { $UnconstrainedPort != "" } {
                        set Error 1
			puts ${UnconstrainedPort}
                }
		if { $UnspecifiedStd != "" } {
			set Error 1
			puts ${UnspecifiedStd}
		}
        }

	close $fd_drc

	return $Error
}


#------------------------------------------------------------------------
# reportCriticalPaths
#------------------------------------------------------------------------
# Assigns the results of the report_timing command to the
# $report Tcl variable, using -return_string. The string is processed to extract the start
# point, end point, path group and path type of each path. After the path information is
# extracted, a summary of that path is printed to the Tcl console.
#------------------------------------------------------------------------

proc showCriticalPath { } {

	set report [report_timing -return_string -max_paths 10]
	set startPoint {}
	set endPoint {}
	set pathGroup {}
	set pathType {}

	# Write the header for string output
	puts [format " %-12s %-12s %-20s -> %-20s" "Path Type" "Path Group" "Start Point" "End Point"]
	puts [format " %-12s %-12s %-20s -> %-20s" "---------" "----------" "-----------" "---------"]
	# Split the return string into multiple lines to allow line by line processing
	foreach line [split $report \n] {
		if {[regexp -nocase -- {^\s*Source:\s*([^[:blank:]]+)((\s+\(?)|$)} $line - startPoint]} {
		} elseif {[regexp -nocase -- {^\s*Destination:\s*([^[:blank:]]+)((\s+\(?)|$)} $line - endPoint]} {
		} elseif {[regexp -nocase -- {^\s*Path Group:\s*([^[:blank:]]+)\s*$} $line - pathGroup]} {
		} elseif {[regexp -nocase -- {^\s*Path Type:\s*([^[:blank:]]+)((\s+\(?)|$)} $line - pathType]} {
		puts [format " %-12s %-12s %-20s -> %-20s" $pathType $pathGroup $startPoint $endPoint]
		}
	}

}

#------------------------------------------------------------------------
# reportCriticalPaths
#------------------------------------------------------------------------
# This function generates a CSV file that provides a summary of the first
# 50 violations for both Setup and Hold analysis. So a maximum number of
# 100 paths are reported.
#------------------------------------------------------------------------
proc reportCriticalPaths { fileName } {
	# Open the specified output file in write mode
	set FH [open $fileName w]
	# Write the current date and CSV format to a file header
	puts $FH "#\n# File created on [clock format [clock seconds]]\n#\n"
	puts $FH "Startpoint,Endpoint,DelayType,Slack,#Levels,#LUTs"
	# Iterate through both Min and Max delay types
	foreach delayType {max min} {
		# Collect details from the 50 worst timing paths for the current analysis
		# (max = setup/recovery, min = hold/removal)
		# The $path variable contains a Timing Path object.
		
		foreach path [get_timing_paths -delay_type $delayType -max_paths 50 -nworst 1] {
		# Get the LUT cells of the timing paths
		set luts [get_cells -filter {REF_NAME =~ LUT*} -of_object $path]
		
		# Get the startpoint of the Timing Path object
		set startpoint [get_property STARTPOINT_PIN $path]
		
		# Get the endpoint of the Timing Path object
		set endpoint [get_property ENDPOINT_PIN $path]
		
		# Get the slack on the Timing Path object
		set slack [get_property SLACK $path]
		
		# Get the number of logic levels between startpoint and endpoint
		set levels [get_property LOGIC_LEVELS $path]
		
		# Save the collected path details to the CSV file
		puts $FH "$startpoint,$endpoint,$delayType,$slack,$levels,[llength $luts]"
		}
	}
	# Close the output file
	close $FH
	puts "CSV file $fileName has been created.\n"
	return 0
}; # End PROC

#------------------------------------------------------------------------
# routeCriticalPaths
#------------------------------------------------------------------------
# The strategy in this sample script is to identify the top 10 critical paths using 
# get_timing_paths, create a list of the net objects ($preRoutes) of those critical paths 
# using get_cells -of, and then route those nets first.
# The script continues after routing the pre-route nets. After route_design completes, 
# the Vivado router unroutes all of the nets in instance u0/u1, then re-routes identified 
# critical nets first, myCritNets. Then the general router finishes any remaining unrouted nets.
#------------------------------------------------------------------------

proc routeCriticalPaths { } {

	route_design -no_timing_driven
	set preRoutes [get_nets -of [get_timing_paths -max_paths 10]]
	## Mirar aquí el slack y si se está muy lejos de cerrar timing
	## En ese caso, se puede rutar de nuevo sólo las rutas críticas (reentrante)
	route_design -nets [get_nets $preRoutes] -delay
	## Y luego el resto

	## Se puede hacer a nivel de cell. Se des-ruta una cell y se trata
	## de cerrar timing empezando por las rutas críticas ¿QDMA?
	#Unroute all the nets in u0/u1, and route the critical nets first
	route_design -unroute [get_nets u0/u1/*]
	route_design -delay -nets [get_nets $myCritNets]

	## Para obtener la localización de la lógica de la ruta crítica:

	get_property LOC [get_cells -of [get_timing_paths -max_paths 10]]
	## Ver página 64 del siguiente documento: 
	## https://www.xilinx.com/support/documentation/sw_manuals/xilinx2012_4/ug904-vivado-implementation.pdf
	## Puede ser interesante fijar el lugar de los elementos de la ruta crítica. Si hemos obtenido 
	## una implementación exitosa, se puede almacenar y luego cargar la localización de dichos elementos.
	## Rutar de nuevo las nets críticas

	set critical_nets [get_nets -of [get_timing_paths -max_paths 85]]

	route_design -nets $critical_nets

}

#------------------------------------------------------------------------
# smartPlaceFlow
#------------------------------------------------------------------------
# This procedure goes through ALL placement strategies to figure out
# what is the one offering the minumum WNS. Is not designed to be part of
# the normal flow, but to be run as a standalone to later apply the 
# best placement directive to the subsequent runs.
#------------------------------------------------------------------------

proc smartPlaceFlow { root_dir } {

	set g_root_dir $root_dir

	## Added SLR directives
	set directives "Explore \
		WLDrivenBlockPlacement \
		ExtraNetDelay_high \
		ExtraNetDelay_low \
		AltSpreadLogic_high \
		AltSpreadLogic_medium \
		AltSpreadLogic_low \
		ExtraPostPlacementOpt \
		ExtraTimingOpt \
		SSI_SpreadLogic_high \
		SSI_SpreadLogic_low \
		SSI_SpreadSLLs \
		SSI_BalanceSLLs \
		SSI_BalanceSLRs \
		SSI_HighUtilSLRs \
		EarlyBlockPlacement"

	# empty list for results
	set wns_results ""
	# empty list for time elapsed messages
	set time_msg ""

	if { [file exists $g_root_dir/dcp/post_opt.dcp] } {
		puts "post synthesis optimization dcp exists"
	} else {
		open_checkpoint $g_root_dir/dcp/synthesis.dcp
		opt_design
	        write_checkpoint -force $g_root_dir/dcp/post_opt.dcp
	}


	foreach oneDirective $directives {
		# open post opt design checkpoint
		open_checkpoint $g_root_dir/dcp/post_opt.dcp
		# run place design with a different directive	
		
		puts "*******************************"
                puts "Start @ [clock format [clock seconds] -format %H:%M:%S]"
		puts "Running place_design -directive $oneDirective"
		puts "*******************************"
                set RefTime [clock seconds]

		place_design -directive $oneDirective

		# append time elapsed message to time_msg list
                puts "*******************************"
		puts "Finish @ [clock format [clock seconds] -format %H:%M:%S]"
                puts "*******************************"

                set LapsedTime [getLapsedTime $RefTime]
		puts "$LapsedTime"

		lappend time_msg "place_design: Time : $LapsedTime" 
		# append wns result to our results list
		set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]
		lappend wns_results $WNS
	}
	
	# print out results at end
	
	set resFile "$g_root_dir/reports/smartPlaceResults.txt"
	set fd_res [open $resFile "w"]


	set i 0
	foreach oneDirective $directives {
		set ResMsg0 "Post Place WNS with directive $oneDirective = [lindex $wns_results $i] "
		set ResMsg1 [lindex $time_msg $i]
		set ConstructMsg "$ResMsg0\r\n$ResMsg1\r\n\r\n"

		puts $fd_res $ConstructMsg
		puts "$ConstructMsg"
		incr i
	}
	
	close $fd_res
}



#------------------------------------------------------------------------
# suggestionFlow
#------------------------------------------------------------------------
# This procedure goes through the RQS directive.
# Vivado makes "suggestions". They can be stored on a file and applied
# later in an iterative way.
#------------------------------------------------------------------------
proc suggestionFlow { root_dir } {

	set g_root_dir $root_dir

	# open dcp
	# opt_design
	# place_design

	report_qor_assessment -file $g_root_dir/reports/postsynth.rpt
	report_methodology -file $g_root_dir/reports/methodology.rpt

	report_qor_suggestions
	### This is run after a design is implemented.
	### Analyzes it and apply timing things in the next
	### loop. Touches properties and switches

	### In fact, it can be run after everystage, to loop
	### over it applying the suggestions.
	write_qor_suggestions -file $g_root_dir/reports/qor.sgs
	read_qor_suggestions -file $g_root_dir/reports/qor.sgs


}

#------------------------------------------------------------------------
# smartPhysOptFlow
#------------------------------------------------------------------------
# This process implements some ideas taken from the HWjedi:
# https://hwjedi.wordpress.com/2017/02/09/vivado-non-project-mode-part-iii-phys-opt-looping/
# Optimization after placement can be performed several times to enhance the chances of the
# rooting step to be successful. This optimizations can be done back to back and several times,
# theoritecally improving the overall picture prior route_design. It should be proven.
# The best directive can be stored and user later in the implementation flow if it exists
#------------------------------------------------------------------------
proc smartPhysOptFlow { } {

	# Open PostPlace dcp
	open_checkpoint $g_root_dir/dcp/post_place.dcp

	# List of phys_opt_design directives
		## Add SLR directives
	set directives "Explore \
			ExploreWithHoldFix  \
			AggressiveExplore  \
			AlternateReplication  \					  
			AggressiveFanoutOpt \
			AddRetime \
			AlternateFlowWithRetiming \
			RuntimeOptimized \
			ExploreWithAggressiveHoldFix \
			Default"
					
	set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]
	
	set NLOOPS 5 
	set TNS_PREV 0
	set WNS_SRCH_STR "WNS="
	set TNS_SRCH_STR "TNS="
	set i 0
	
	if { $WNS < 0 } {
		## Choose n number of directives and loop over then NLOOPS times
		## This might or might not improve timing, need to be proven
		## The vivado.log can be the only place to get the TNS
		## Grep is quicker than call vivado timing paths
		for {set i 0} {$i < $NLOOPS} {incr i} {
			phys_opt_design -directive AggressiveExplore
			set WNS [ exec grep $WNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$WNS_SRCH_STR//p" | cut -d\  -f 1]                                    
			set TNS [ exec grep $TNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$TNS_SRCH_STR//p" | cut -d\  -f 1]
			puts "WNS=$WNS"
			puts "TNS=$TNS"
			
			if { $TNS == $TNS_PREV && $i > 0 } {
				puts "TNS didn't improved further, stopping smartPhysOptFlow"	
				break
			}
			if { $WNS >= 0.000 } {
				puts "WNS is possitive, smartPhysOptFlow succeded"	
				break
			}			
			
			set TNS_PREV $TNS
			
			phys_opt_design -directive AggressiveFanoutOpt
			set WNS [ exec grep $WNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$WNS_SRCH_STR//p" | cut -d\  -f 1]                                    
			set TNS [ exec grep $TNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$TNS_SRCH_STR//p" | cut -d\  -f 1]
			puts "WNS=$WNS"
			puts "TNS=$TNS"
			
			if { $TNS == $TNS_PREV && $i > 0 } {
				puts "TNS didn't improved further, stopping smartPhysOptFlow"	
				break
			}
			if { $WNS >= 0.000 } {
				puts "WNS is possitive, smartPhysOptFlow succeded"	
				#INFO: [Vivado_Tcl 4-383] Design worst setup slack (WNS) is greater than or equal to 0.000 ns. Skipping all physical synthesis optimizations.
				break
			}			
			
			set TNS_PREV $TNS
			
			phys_opt_design -directive AlternateFlowWithRetiming
			set WNS [ exec grep $WNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$WNS_SRCH_STR//p" | cut -d\  -f 1]                                    
			set TNS [ exec grep $TNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$TNS_SRCH_STR//p" | cut -d\  -f 1]
			puts "WNS=$WNS"
			puts "TNS=$TNS"
			
			if { $TNS == $TNS_PREV && $i > 0 } {
				puts "TNS didn't improved further, stopping smartPhysOptFlow"	
				break
			}
			if { $WNS >= 0.000 } {
				puts "WNS is possitive, smartPhysOptFlow succeded"	
				break
			}			
			
			set TNS_PREV $TNS

		}
	
	} else {
		puts "WNS is possitive, smartPhysOptFlow won't be run"	
	}
	
}



#------------------------------------------------------------------------
## GetTimeRef
##------------------------------------------------------------------------
## This process returns a time stamp comparison, the actual against the 
## the one is passed as a parameter
##------------------------------------------------------------------------

proc getLapsedTime { ReferenceTime } {

        #set ActualTime [ clock format [ clock seconds ] -format %H:%M:%S ]
        #set InitDate [ clock format [ clock seconds ] -format %d/%m/%Y ]

	set ActualTime [clock seconds]

	set LapsedTime [expr $ActualTime - $ReferenceTime]

	## Check if this can be done:
	return [clock format $LapsedTime -format %H:%M:%S -gmt true]

}


set PlaceDirectives "Explore \
	WLDrivenBlockPlacement \
	ExtraNetDelay_high \
	ExtraNetDelay_low \
	AltSpreadLogic_high \
	AltSpreadLogic_medium \
	AltSpreadLogic_low \
	ExtraPostPlacementOpt \
	ExtraTimingOpt \
	SSI_SpreadLogic_high \
	SSI_SpreadLogic_low \
	SSI_SpreadSLLs \
	SSI_BalanceSLLs \
	SSI_BalanceSLRs \
	SSI_HighUtilSLRs \
	EarlyBlockPlacement \
	RQS"


set PhysOptDirectives "Explore \
	ExploreWithHoldFix  \
	AggressiveExplore  \
	AlternateReplication  \					  
	AggressiveFanoutOpt \
	AddRetime \
	AlternateFlowWithRetiming \
	RuntimeOptimized \
	ExploreWithAggressiveHoldFix \
	RQS \					
	Default"


set OptDesignDirectives "Explore \
	ExploreArea \
	ExploreSequentialArea \
	AddRemap \
	NoBramPowerOpt \
	ExploreWithRemap \
	RQS \
	Default"
