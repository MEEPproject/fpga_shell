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


proc reportPlace { g_root_dir } {

	set postPlaceDir $g_root_dir/reports/post_place

	file mkdir $postPlaceDir
	open_checkpoint $g_root_dir/dcp/post_place.dcp
        report_clock_utilization -file $postPlaceDir/clock_utilization.rpt
	report_methodology -file $postPlaceDir/methodology.rpt
	report_utilization -hierarchical -file $postPlaceDir/utilization_hier.rpt
	report_utilization -file $postPlaceDir/utilization_summary.rpt
        report_utilization -slr -file $postPlaceDir/utilization_slr.rpt
	report_timing_summary -file $postPlaceDir/timing_summary.rpt
        reportCriticalPaths $postPlaceDir/critical_path_report.csv
}


reportPlace $g_root_dir

