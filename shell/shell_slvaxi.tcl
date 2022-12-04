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
# Date: 02.12.2022
# Description: 

# An interconnect needs to be added, considering the potentially diferent clock domains

set g_SLVAXI_ifname [dict get $SLVAXIentry IntfLabel]
set g_SLVAXI_CLK    [dict get $SLVAXIentry SyncClk Name]
set g_SLVAXI_freq   [dict get $SLVAXIentry SyncClk Freq]
set g_SLVAXIClkPort [dict get $SLVAXIentry SyncClk Label]

set SLVAXIaddrWidth [dict get $SLVAXIentry AxiAddrWidth]

set SLVAXIbaseAddr [dict get $SLVAXIentry BaseAddr]
set SLVAXIMemRange [expr {2**$SLVAXIaddrWidth/1024}]

putmeeps "Deploying AXI Lite number $slv_axi_ninstances"

set_property -dict [list CONFIG.NUM_MI [expr $slv_axi_ninstances + 1]] [get_bd_cells axi_xbar_pcie_lite]	
connect_bd_net [get_bd_pins axi_xbar_pcie_lite/M0${slv_axi_ninstances}_ACLK] [get_bd_pins rst_ea_$g_SLVAXIClkPort/slowest_sync_clk]
connect_bd_net [get_bd_pins rst_ea_${g_SLVAXIClkPort}/peripheral_aresetn] [get_bd_pins axi_xbar_pcie_lite/M0${slv_axi_ninstances}_ARESETN] 

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $g_SLVAXI_ifname
set_property CONFIG.PROTOCOL AXI4LITE [get_bd_intf_ports /$g_SLVAXI_ifname]
set_property CONFIG.ADDR_WIDTH $SLVAXIaddrWidth [get_bd_intf_ports /$g_SLVAXI_ifname]
set_property CONFIG.FREQ_HZ $g_SLVAXI_freq [get_bd_intf_ports /$g_SLVAXI_ifname]

connect_bd_intf_net [get_bd_intf_ports $g_SLVAXI_ifname] -boundary_type upper [get_bd_intf_pins axi_xbar_pcie_lite/M0${slv_axi_ninstances}_AXI]

# Increase the counter to track the number of slaves added	
incr slv_axi_ninstances

save_bd_design

#### SLVAXI memory map	

putdebugs "SLVAXIBaseAddr $SLVAXIbaseAddr"
putdebugs "SLVAXIMemRange $SLVAXIMemRange"
putdebugs "SLVAXIaddrWidth $SLVAXIaddrWidth"

#Hardcode the mem range to 4K. It might be passed as a parameter via accelerator_def.csv
set SLVAXIMemRange 4

#save_bd_design
assign_bd_address [get_bd_addr_segs {$g_SLVAXI_ifname/S_AXI/Reg }]
set_property range ${SLVAXIMemRange}K [get_bd_addr_segs qdma_0/M_AXI_LITE/SEG_${g_SLVAXI_ifname}_Reg]
set_property offset ${SLVAXIbaseAddr} [get_bd_addr_segs qdma_0/M_AXI_LITE/SEG_${g_SLVAXI_ifname}_Reg]


#assign_bd_address [get_bd_addr_segs {$UartCoreName/S_AXI/Reg }]
#set_property range ${SLVAXIMemRange}K [get_bd_addr_segs qdma_0/M_AXI_LITE/SEG_${g_SLVAXI_ifname}_Reg]
#set_property offset $SLVAXIbaseAddr   [get_bd_addr_segs qdma_0/M_AXI_LITE/SEG_${g_SLVAXI_ifname}_Reg]

#putmeeps "SLV_AXI has been configured"
