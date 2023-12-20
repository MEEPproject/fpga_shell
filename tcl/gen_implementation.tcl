# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Solderpad Hardware License v 2.1 (the "License");
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
# 
#     http://www.solderpad.org/licenses/SHL-2.1
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Daniel J.Mazure, BSC-CNS
# Date: 22.02.2022
# Description: 


source [pwd]/tcl/environment.tcl
source $g_root_dir/tcl/impl_utils.tcl

if { $::argc > 0 } {

 set g_root_dir [lindex $argv 0]
 set g_dcp_on     "true"
 set g_quick_impl "false"
 puts "Root directory is $g_root_dir"

} else { 
 puts "Bad usage. This script needs to receive the root directory as an argument"
 return 0
} 

if { $::argc > 1} { 

 set g_dcp_on  [lindex $argv 1]
 puts "Post opt and post place dcp generation is set to $g_dcp_on"

}

if { $::argc > 2} { 

 set g_quick_impl  [lindex $argv 2]
 puts "Fast Implementation is set to $g_quick_impl"

}

proc implementation { g_root_dir g_place_directive g_route_directive g_dcp_on g_quick_impl } {

	set RefTime [clock seconds]
	## It is assumed a dcp folder containing the synthesis dcp already exists
	file mkdir $g_root_dir/reports

	### Check as early as possible that all logical ports and all I/O
	### standards are specified.
	### This likely shouldn't happen as the Shell is "fixed", but it is
	### better to detect if that happen here than in the bitgen phase.
	if { [reportEarlyDRC $g_root_dir] == 1 } {
		puts "Detected Unspecified Logic Levels or Unconstraiend ports."
		puts "Implementation will not continue. Check the pinout."
		# TODO: Check if this is working commenting a physical top level pin
		exit 1
	}


	if { $g_quick_impl == "true" } {
		set opt_design_directive "RuntimeOptimized"
		set place_design_directive "Quick"
		set phys_opt_design_directive "Default"
		set route_design_directive "Quick"
		set post_route_directive "Default"
	} else {
		set opt_design_directive "Explore"
		set place_design_directive "$g_place_directive"
		set phys_opt_design_directive "Default"
		set route_design_directive "$g_route_directive"
		set post_route_directive "AggressiveExplore"
	}


	#opt_design
	# opt_design can be called with switches: opt_design -retarget -sweep
	# For example, a congested design may benefit from skipping the remap option.
	# By default, opt_design does: -retarget -sweep -remap -propconst -resynth_area
	# Non-default: -area_mode -effort_level <arg>  -verbose
	opt_design -directive Explore
	

	# Store the Lapsed time up to opt_desing finish
	set Lapsed2optTime [getLapsedTime $RefTime]
	puts "Lapsed time after opt_design: $Lapsed2optTime"
	puts "--------------------------------------"

	if { $g_dcp_on == "true" } {
            write_checkpoint -force $g_root_dir/dcp/post_opt.dcp
	}	

	# Optional Power Optimization
	#power_opt_design	
	# TODO: Add a time stamp from here to the end of the process, so it can be compared
	# with other configurations -Vivado flow or when the place directive is set after
	# getting it with ExhaustivePlaceFlow
	
	puts "Place design starting at:"
	set InitDate [ clock format [ clock seconds ] -format %d/%m/%Y ]
	set InitTime [ clock format [ clock seconds ] -format %H:%M:%S ]
	puts "$InitTime on $InitDate"
	place_design -directive $place_design_directive

	set Lapsed2placeTime [getLapsedTime $RefTime] 
	puts "Lapsed time after place_design: $Lapsed2placeTime"
        puts "--------------------------------------"

	puts "------------------------"
	puts "Place design Finished at:"
	puts [ clock format [ clock seconds ] -format %d/%m/%Y ]
	puts [ clock format [ clock seconds ] -format %H:%M:%S ]
	puts "\(started at $InitTime on $InitDate\)"
	puts "Directive used: $place_design_directive"
	puts "------------------------"

	# Optionally run optimization if there are timing violations after placement
	
	set PhysOptDirectives "Explore \
        ExploreWithHoldFix  \
        AggressiveExplore  \
        AlternateReplication  \
        AggressiveFanoutOpt \
        AddRetime \
        AlternateFlowWithRetiming \
        RuntimeOptimized \
        ExploreWithAggressiveHoldFix \
        Default"
	set fd_opt [open $g_root_dir/reports/opt_strategies.rpt "w"] 

	set i 0
	set nloops [llength $PhysOptDirectives]
	set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
	set PrevSlack $CurrentSlack

	for {set i 0} {$i < $nloops} {incr i} {		

	 set CurrentDirective [lindex $PhysOptDirectives $i]

     puts "Running post-place phys_opt_design iteration $i/$nloops with directive $CurrentDirective"
	#  if { [expr $CurrentSlack < 0] } {
	#   puts "Found setup timing violations => running physical optimization"
	  phys_opt_design -directive $CurrentDirective
	  # Get the Slack after the optimization
	  set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
	  puts "\r\n-------------------------"
	  set Msg0 "Directive Applied: $CurrentDirective\r\nWNS: $CurrentSlack\r\nPrevious WNS: $PrevSlack"
	  puts $Msg0
	  puts $fd_opt $Msg0
	  set OptMsg "Directive $CurrentDirective improved WNS by [expr abs($PrevSlack - $CurrentSlack)]ns"
	  puts "$OptMsg"
	  puts $fd_opt $OptMsg
          set PrevSlack $CurrentSlack
	#  } else {
	#   set SkipMsg "Skipping phys_opt phase \($CurrentDirective\) as current slack is +${CurrentSlack}ns"
	#   puts "$SkipMsg"
	#   puts $fd_opt $SkipMsg
	#  }
	 puts "-------------------------\r\n"
	 if {$g_quick_impl == "true" } {
		# Don't run the optimization loop when quick flag is enabled. Break the foreach loop
		break;
	 }
	}

	close $fd_opt

	set Lapsed2physOptTime [getLapsedTime $RefTime]
	puts "Lapsed time after phys_opt_design: $Lapsed2physOptTime"
        puts "--------------------------------------"
	
	#set critical_nets [get_nets -of [get_timing_paths -max_paths 85]]
	#route_design -nets $critical_nets

	if { $g_dcp_on == "true" } { 
            write_checkpoint -force $g_root_dir/dcp/post_place.dcp 	
	}	

	# if { [expr $CurrentSlack < -1.000 ] && $g_quick_impl != "true"} {
	# 	puts "route_design will not be run as the WNS is above 1.000 "
	# 	puts "Implementation Failed. Check the timing reports to study how to improve timing"
	# 	## TODO: Quality of Results can be used as another criteria to not going further
	#     return 1
	# }	


  # Explore other routing strategies
  set RouteDirectives "NoTimingRelaxation \
        Explore \
        MoreGlobalIterations \
        HigherDelayCost \
        AdvancedSkewModeling \
        AlternateCLBRouting \
        AggressiveExplore  \
        Default"

  set route_loops [llength $RouteDirectives]
  for {set route_loop 0} {$route_loop < $route_loops} {incr route_loop} {

    set route_design_directive [lindex $RouteDirectives $route_loop]
    puts "Running route_design iteration $route_loop/$route_loops with directive $route_design_directive"
    route_design -directive $route_design_directive

    set Lapsed2routeTime [getLapsedTime $RefTime]
    puts "Lapsed time after route_design: $Lapsed2routeTime"
    puts "--------------------------------------"

	## TODO: Directives can be added here to go the extra mile. E.g, the WNS is below -0.1 after 
	## default routing
    # set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
	# if { [expr $CurrentSlack < 0.000] && [expr $CurrentSlack > -0.200] } {
    #         puts "Running post-route phys_opt_design iteration with directive $post_route_directive"
    #         phys_opt_design -directive $post_route_directive
    # }

    set i 0
    set nloops [llength $PhysOptDirectives]
    set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
    set PrevSlack $CurrentSlack
    # Post-Route Physical Optimization is effective when WNS is above -0.5ns, and could be stuck otherwise
    if { [expr {$CurrentSlack >= -0.5 || $route_loop == ($route_loops-1)}] } {
     for {set i 0} {$i < $nloops} {incr i} {
      set CurrentDirective [lindex $PhysOptDirectives $i]
      puts "Running post-route phys_opt_design iteration $i/$nloops with directive $CurrentDirective"
      phys_opt_design -directive $CurrentDirective
      # Get the Slack after the optimization
      set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
      puts "\r\n-------------------------"
      puts "Post-route phys_opt_design Directive Applied: $CurrentDirective\r\nWNS: $CurrentSlack\r\nPrevious WNS: $PrevSlack"
      puts "Post-route phys_opt_design Directive $CurrentDirective improved WNS by [expr abs($PrevSlack - $CurrentSlack)]ns"
      set PrevSlack $CurrentSlack
      puts "-------------------------\r\n"
      if {$g_quick_impl == "true" } {
      # Don't run the optimization loop when quick flag is enabled. Break the foreach loop
      break;
      }
     }
    }

    puts "\r\n-------------------------"
    puts "route_design iteration $route_loop/$route_loops with directive $route_design_directive finished: WNS = $CurrentSlack"
    puts "-------------------------\r\n"
    write_checkpoint -force $g_root_dir/dcp/implementation.dcp
    if { [expr $CurrentSlack >= 0.000] } {
      break
    }
  }

    report_utilization -file $g_root_dir/reports/utilization.rpt
    set CurrentSlack [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]

	# The netlist file below can size ~220MB, need to check if it is worth
	#write_verilog -force $g_root_dir/reports/impl_netlist.v -mode timesim -sdf_anno true
	# TODO: Create a filter to write only the VIOLATED nets
	set Lapsed2ImplTime [getLapsedTime $RefTime]
	puts "Lapsed Implementation time: $Lapsed2ImplTime"
    puts "--------------------------------------"

	####### The following lines are used to store the more relevant desingn parameters into a file ###
	# Lapsed time for all steps
	# Directives used
	# WNS, TNS
	# Failing paths, if they exist
	# More?
	
    set fd_sum [open $g_root_dir/reports/summary.rpt "w"]

	puts $fd_sum "======================================="
	puts $fd_sum "== FPGA Shell implementation summary =="
    puts $fd_sum "======================================="
	puts $fd_sum ""
	puts $fd_sum "1. Timing:"

    if { [expr $CurrentSlack < 0.000] } { 

	  puts $fd_sum "* Timing constraints are not met"
	  set WorstTimingPath [get_timing_paths -max_paths 1 -nworst 1 -setup]
	  puts $fd_sum "Critical Path:\r\n$WorstTimingPath\r\n"

	} else {
        puts $fd_sum "* The design closed timing"
	}

	puts $fd_sum "Design WNS=${CurrentSlack}ns"

	puts $fd_sum "2. Directives:"
    puts $fd_sum "* Place Directive used: $place_design_directive"
    puts $fd_sum "* Route Directive used: $route_design_directive"
    puts $fd_sum "3. Lapsed timestamps to reach stages:"
    puts $fd_sum "* Post synthesis optimization @ $Lapsed2optTime"
	puts $fd_sum "* Post place                  @ $Lapsed2placeTime"
    puts $fd_sum "* Post place optimization     @ $Lapsed2physOptTime"
    puts $fd_sum "* Post route                  @ $Lapsed2routeTime"
    puts $fd_sum "* Post route Opt              @ $Lapsed2ImplTime"

	close $fd_sum
}

### MAIN PROGRAM

open_checkpoint $g_root_dir/dcp/synthesis.dcp
set g_board_part [string range [get_property PART [current_design]] 2 5]

# Optionaly add a place directive as an argument.

set directivesFile $g_root_dir/shell/directives.tcl

# ever tried strategies here
set g_place_directive "ExtraNetDelay_low"
set g_place_directive "Explore"
set g_place_directive "ExtraTimingOpt"
set g_place_directive "Auto_2"

set g_route_directive "NoTimingRelaxation"

if { $g_board_part == "u280" }  {
  # board-specific strategies in case it helps for heavy designs
  set g_place_directive "ExtraNetDelay_high"
}

# SmartPlace.tcl script creates a directives file when called.

if {[file exists $directivesFile]} {
	source $directivesFile
	puts "Stored place directive $g_place_directive will be used"
}

	
implementation $g_root_dir $g_place_directive $g_route_directive $g_dcp_on $g_quick_impl

