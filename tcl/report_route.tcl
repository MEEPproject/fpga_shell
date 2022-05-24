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
 set g_root_dir $::argv
 puts "Root directory is $g_root_dir"
} else {
 puts "Bad usage: this script needs an argument"
 exit -1
}


proc reportRoute { g_root_dir } {

	set routeDir $g_root_dir/reports/post_route

	file mkdir $routeDir
	open_checkpoint $g_root_dir/dcp/implementation.dcp
	report_methodology -file $routeDir/methodology.rpt
        report_design_analysis -timing -extend -file $routeDir/design_analysis_timing.rpt
        report_design_analysis -max_paths 50 -setup -file $routeDir/design_analysis_setup.rpt
        report_design_analysis -complexity -file $routeDir/design_analysis_complexity.rpt
        report_design_analysis -congestion -file $routeDir/design_analysis_congestion.rpt
        report_route_status -file $routeDir/route_status.rpt
        report_timing_summary -file $routeDir/timing_summary.rpt
        report_timing_summary -delay_type min_max -report_unconstrained -warn_on_violation -check_timing_verbose -input_pins -routable_nets -file $routeDir/timing_summary.rpt
        report_timing -setup -file $routeDir/timing_setup.rpt
        report_timing -hold -file $routeDir/timing_hold.rpt
        report_power -file $routeDir/power.rpt
        report_drc -file $routeDir/drc.rpt
	reportCriticalPaths $routeDir/critical_path_report.csv

}

reportRoute $g_root_dir

