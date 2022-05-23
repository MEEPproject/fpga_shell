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
# Date: 18.05.2022
# Description: 

set NumXmasters [get_property  [list CONFIG.NUM_MI ] [get_bd_cells smartconnect_pcie_dma]]

# For the ethernet over pci implementation, we need 2 extra ports in the crossbar controlled by QDMA
# 1) To access the Ethernet IP
# 2) To access the Shared memory between PCI and the Ethernet IP

set NewXmasters [expr {$NumXmasters+2}]
set_property -dict [list CONFIG.NUM_MI $NewXmasters] [get_bd_cells smartconnect_pcie_dma]

# Obtain the ETH intf
set EthXbarIntf [expr {$NumXmasters+1}]

if { [expr {$EthXbarIntf < 10 }]} {
    set $EthXbarIntf "0${EthXbarIntf}"  
    putdebugs "Actual number of dma interconnect master ports: $NumXmasters"
    putdebugs "New Ethernet interface is assigned to port number $EthXbarIntf"
}

set XbarEthIntfPin [get_bd_intf_pins smartconnect_pcie_dma/M${EthXbarIntf}_AXI]



save_bd_design
