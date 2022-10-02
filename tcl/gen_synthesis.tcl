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
 set g_project_dir $::argv
 puts "project directory is $g_project_dir"
}

open_project ${g_project_dir}/${g_project_name}.xpr

proc synthesis { g_root_dir g_number_of_jobs} {

	set number_of_jobs $g_number_of_jobs
	reset_run synth_1
	launch_runs synth_1 -jobs ${g_number_of_jobs}

	# Obtain the Out-Of-Context IP list to be synthesized
	set synthRuns [get_runs -filter {NAME=~ "*_synth_1"}]

	puts "Waiting for the Out Of Context IPs (Block Design) to be synthesized."
	puts "Task Started at:"
        set InitDate [ clock format [ clock seconds ] -format %d/%m/%Y ]
        set InitTime [ clock format [ clock seconds ] -format %H:%M:%S ]
        puts "$InitTime on $InitDate"

	foreach OOCrun $synthRuns {
	  wait_on_run $OOCrun
	}	

	puts "**************************************************************"
	puts "All OOC IP synthesis completed. Switch to the top level module"
        puts "**************************************************************"

	wait_on_run synth_1

        puts "Task Started at:"
        puts "$InitTime on $InitDate"
	
        puts "Finished at:"
        puts [ clock format [ clock seconds ] -format %d/%m/%Y ]
        puts [ clock format [ clock seconds ] -format %H:%M:%S ]

	open_run synth_1

	set status [get_property STATUS [get_runs synth_1]]

	puts "$status"

	if { $status != "synth_design Complete!"} {	
		puts "Design synthesis failed, exiting ..."
		exit 1
	}
	
	file mkdir $g_root_dir/dcp
	file mkdir $g_root_dir/reports

	write_checkpoint -force $g_root_dir/dcp/synthesis.dcp
	
	## Synthesis log. The "system_top" is hardcoded as it is always the shell top 
	## module name. It could be treated as a global variable either.
	set synthLogPath $g_root_dir/reports/synthesis
	set synthLog $synthLogPath/synthesis.rpt
	file mkdir $synthLogPath
	
	file copy -force $g_root_dir/project/system.runs/synth_1/system_top.vds $synthLog

	reportUnconnectedPins $synthLog 
	
	## Add this into a open-while loop to parse line by line
	#set UndrivenPins [regexp -all -inline {WARNING: [Synth 8-3295].*$} $line]
	
	
}

synthesis $g_root_dir $g_number_of_jobs
