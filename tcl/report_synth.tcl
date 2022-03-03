# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
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


proc reportSynth { g_root_dir } {

	set synthDir $g_root_dir/reports/synthesis

	file mkdir $synthDir
	open_checkpoint $g_root_dir/dcp/synthesis.dcp
	report_methodology -file $synthDir/methodology.rpt
	report_utilization -hierarchical -file $synthDir/utilization_hier.rpt
        report_timing_summary -file $synthDir/timing_summary.rpt
	reportCriticalPaths $synthDir/critical_path_report.csv
	# TODO: Add any other report that could be useful at this stage

}

reportSynth $g_root_dir

