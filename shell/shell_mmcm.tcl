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



###############################################################
# Set MMCM using the clocks extracted from the definition file
###############################################################

set i 1
set n 0
set ConfMMCMString " "
# 1GHz, arbitrarily High
set slowestSyncCLK 1000000000
set APBclkCandidate "None"
set RstExist 0

if { $ARSTDef ne "" } {
	set AsyncRstName  [dict get $ARSTDef IntfLabel]
	set AsyncRstLevel [dict get $ARSTDef Polarity]

	set RstExist 1	
	create_bd_port -dir I -type rst $AsyncRstName	
	set_property CONFIG.POLARITY ACTIVE_$AsyncRstLevel [get_bd_ports $AsyncRstName]
}

foreach clkObj $ClockList {

	### Spaces at the end of a string are necessary when using append
	# CLKOUT1 is enabled by default, skip it. 0 doesn't exist.
	if { $i > 1 } {
		set ConfMMCM "CONFIG.CLKOUT${i}_USED true "
		append ConfMMCMString "$ConfMMCM"
	}
	set ClkFreq  [dict get $clkObj ClkFreq]
	set ClkName  [dict get $clkObj ClkName]
	set ClkFreqMHz [expr $ClkFreq/1000000 ]
	putmeeps "Configuring MMCM output $i: ${ClkFreqMHz}MHz"
	set ConfMMCM "CONFIG.CLKOUT${i}_REQUESTED_OUT_FREQ ${ClkFreqMHz} "
	append ConfMMCMString "$ConfMMCM"
	
	#set ConfMMCM "CONFIG.CLK_OUT${i}_PORT CLK${n} "
	#append ConfMMCMString "$ConfMMCM"
	incr i
	incr n

	
	#Get the slowest clock and check if there is any below
	#100MHz. If it doesn't, it needs to be created to source
	#the HBM APB port.
	
	set currentClk [dict get $clkObj ClkFreq]
	
	if { $currentClk < $slowestSyncCLK } {
		set slowestSyncCLKname [dict get $clkObj Name]
		set slowestSyncCLK $currentClk
		if { 50000000 <= $currentClk && $currentClk <= 100000000} {
			set APBclkCandidate [dict get $clkObj Name]
		}
	}
	if { $currentClk == 125000000 } {
		set ETHclkCandidate [dict get $clkObj Name]

	}

	putdebugs $ConfMMCM

}

putmeeps "Slowest CLK: $slowestSyncCLKname, APBcandidate: $APBclkCandidate"

### An APB clock is added to the list if no candidate is found
# TODO: What if HBM is not selected?
set APBclk ""
set ETHinitCLK ""

if { $APBclkCandidate ne "None" } {
	
	set APBclk $APBclkCandidate
	
	putmeeps "APB CLK: $APBclk"

} else {
	### +2 because the list is at this point one element short and because
	### The Clock wizard numeration differs and doesn't have a 0
	set numClk [expr [llength ClockList] +2]
	set d_clock [dict create Name CLK${numClk}]
	#a 50MHz clock needs to be created, default APB clock
	# ClockList
	dict set d_clock ClkNum  CLK${numClk}
	dict set d_clock ClkFreq 50000000
	dict set d_clock ClkName APBclk
	
	set APBclk "CLK[expr $numClk -1]"
	
	set ClockList [lappend ClockList $d_clock]	

	putdebugs "Adding APB Clk to the list: $ClockList"
	
	set ConfMMCM "CONFIG.CLKOUT${numClk}_USED true "
	append ConfMMCMString "$ConfMMCM"
	
	set ConfMMCM "CONFIG.CLKOUT${numClk}_REQUESTED_OUT_FREQ 50 "
	append ConfMMCMString "$ConfMMCM"
	
	# set ConfMMCM "CONFIG.CLK_OUT${numClk}_PORT CLK[expr [llength ClockList]+1] "
	# append ConfMMCMString "$ConfMMCM"		
	
}

set EthInitClk [list "EthInitClk" 125000000]
set NewMMCMconf [AddClk2MMCM $ClockList $ConfMMCMString $EthInitClk ]

putdebugs $ClockList
putdebugs [lindex $NewMMCMconf 0]

putdebugs $ConfMMCMString
putdebugs [lindex $NewMMCMconf 1]


set ClockList [lindex $NewMMCMconf 0]
set ConfMMCMString [lindex $NewMMCMconf 1]


# BOARD_FREQ is defined in the environment file.
	
   set ClockParamList [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
   CONFIG.USE_RESET {false} \
   CONFIG.PRIM_IN_FREQ $BOARD_FREQ \
   CONFIG.USE_LOCKED {true} \
   ]

  append ClockParamList $ConfMMCMString
  
  putdebugs "MMCM configuration: $ClockParamList"

  #Depends on the board
  set resetn [ create_bd_port -dir I -type rst resetn ]

  #Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
  set_property -dict $ClockParamList $clk_wiz_1
    
  make_bd_intf_pins_external  [get_bd_intf_pins clk_wiz_1/CLK_IN1_D]
  # TODO: Change to a more descriptive name, e.g ext_clk
  set_property name sysclk1 [get_bd_intf_ports CLK_IN1_D_0]


  # APBClockPin defaults to empty. It will be populated here by a new MMCM output or by
  # an APBclkCandidate in the HBM script in case it exists.
  set APBClockPin ""
  set APBRstPin ""

  set n 1

	foreach clkObj $ClockList {

		set ClkNum  [dict get $clkObj ClkNum]
		set ClkName [dict get $clkObj ClkName]

		set RstSync [dict get $clkObj ClkRst]
		set RstPol  [dict get $clkObj ClkRstPol]
		
		# TODO: we dont want the APB clock to be external and we do want the PCIe clock in case
		# it is used as an interface
		
		if { !($ClkName == "APBclk" || $ClkName == "EthInitClk")} {

			create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ea_$ClkNum
			connect_bd_net [get_bd_ports resetn] [get_bd_pins rst_ea_$ClkNum/ext_reset_in]
			### Create the reset list to be used later
			connect_bd_net [get_bd_pins rst_ea_$ClkNum/slowest_sync_clk] [get_bd_pins clk_wiz_1/clk_out${n}]
			### TODO: connect DCM locked signal
			if { $RstExist == 1 } {
				connect_bd_net [get_bd_ports $AsyncRstName] [get_bd_pins rst_ea_$ClkNum/aux_reset_in]
			}

			## Make the clocks external and user-usable
			## User clocks
			
			create_bd_port -dir O -type clk $ClkName
			connect_bd_net [get_bd_ports $ClkName] [get_bd_pins clk_wiz_1/clk_out${n}]

			## Create Synchronous Reset port

			if { $RstSync != "" } {
				create_bd_port -dir O -type rst $RstSync
				# TODO: Make case insensitive
				if { $RstPol == "HIGH"  } {
					connect_bd_net [get_bd_ports $RstSync] [get_bd_pins rst_ea_$ClkNum/peripheral_reset]

				} else {
                	connect_bd_net [get_bd_ports $RstSync] [get_bd_pins rst_ea_$ClkNum/peripheral_aresetn]
				}
			}
			
			
			incr n
		} else {
			# We know APB Clk, if it exists in the list, is the last one, so we can
			# still use the index n to refer to the MMCM clock output
			# TODO: Refactor this whole thing
			set n [expr $n-1]
			
			set APBClockPin [get_bd_pins clk_wiz_1/clk_out${n}]
			create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_apb
                        connect_bd_net [get_bd_ports resetn] [get_bd_pins rst_apb/ext_reset_in]
			connect_bd_net $APBClockPin [get_bd_pins rst_apb/slowest_sync_clk]
			set APBRstPin [get_bd_pins rst_apb/peripheral_aresetn]


		}

	}

 # TODO: Now we know Ethernet Init Clk is the last one, but this needs to be refactored
 incr n

 set MMCMLockedPin [get_bd_pins clk_wiz_1/locked]
 set EthInitClkPin [get_bd_pins clk_wiz_1/clk_out${n}]

  

 save_bd_design  






