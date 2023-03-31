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

set PortList [lappend PortList $g_uart_file]

set g_UART_MODE   [dict get $UARTentry Mode]
set g_UART_ifname [dict get $UARTentry IntfLabel]
set g_UART_irq    [dict get $UARTentry IRQ]
set g_UART_CLK	  [dict get $UARTentry SyncClk Name]
set g_CLK0_freq   [dict get $UARTentry SyncClk Freq]
set g_UARTClkPort [dict get $UARTentry SyncClk Label]

# set UARTaddrWidth [dict get $UARTentry AxiAddrWidth]

# Default to non-empty value for the special case where
# the UART is going to be used via PATCH. In this case,
# there is no associated axi bus values comming from the EA.

# if { $UARTaddrWidth == "0" } {
#     set UARTaddrWidth "13"	
# }

#putdebugs "UART? $g_UART_CLK"

# UART IPs are definded in tcl/vivado_ip_tables.tcl
if { $g_UART_MODE eq "xilinx" } {

    set UartCoreName "Xilinx_axi_uart_0"
    set UartCoreIP $XilinxUart

} elseif { $g_UART_MODE eq "normal" } {

    # MEEP UART

    set UartCoreName "MEEP_uart_0"
    set UartCoreIP $MEEPUart

    ### Initialize the IPs
    putmeeps "Packaging UART IP..."
    exec make -C "$g_root_dir/ip/pulp_uart" FPGA_BOARD=$g_board_part
    putmeeps "... Done."
    update_ip_catalog -rebuild

}

    create_bd_port -dir I -type data rs232_rxd
    create_bd_port -dir O -type data rs232_txd


if { $g_UART_MODE eq "simple"} {

	create_bd_port -dir O -type data ${g_UART_ifname}_rxd
	create_bd_port -dir I -type data ${g_UART_ifname}_txd
	connect_bd_net [get_bd_ports ${g_UART_ifname}_txd] [get_bd_ports rs232_txd]
	connect_bd_net [get_bd_ports rs232_rxd] [get_bd_ports ${g_UART_ifname}_rxd]

} else {

        # set UARTbaseAddr [dict get $UARTentry BaseAddr]
        # set UARTMemRange [expr {2**$UARTaddrWidth/1024}]

	putmeeps "Deploying $UartCoreName"

	save_bd_design
	create_bd_cell -type ip -vlnv $UartCoreIP $UartCoreName
	connect_bd_net [get_bd_ports rs232_rxd] [get_bd_pins $UartCoreName/sin]
	connect_bd_net [get_bd_ports rs232_txd] [get_bd_pins $UartCoreName/sout]
	connect_bd_net [get_bd_pins $UartCoreName/s_axi_aclk] [get_bd_pins rst_ea_$g_UARTClkPort/slowest_sync_clk]
	connect_bd_net [get_bd_pins rst_ea_${g_UARTClkPort}/peripheral_aresetn] [get_bd_pins $UartCoreName/s_axi_aresetn]

    # Now all AXI properties are inhereted from the IP
	make_bd_intf_pins_external  [get_bd_intf_pins $UartCoreName/S_AXI]
	set_property name $g_UART_ifname [get_bd_intf_ports S_AXI_0]
	# set_property CONFIG.ADDR_WIDTH $UARTaddrWidth [get_bd_intf_ports /$g_UART_ifname]
	# set_property -dict [list CONFIG.G_ADDR_WIDTH $UARTaddrWidth] [get_bd_cells $UartCoreName]	
	# set_property CONFIG.FREQ_HZ $g_CLK0_freq [get_bd_intf_ports /$g_UART_ifname]

	#Deal with no IRQ scenario
	if { $g_UART_irq != "none" } {
		make_bd_pins_external  [get_bd_pins $UartCoreName/ip2intc_irpt]
		set_property name $g_UART_irq [get_bd_ports ip2intc_irpt_0]
	}	

	set_property CONFIG.ASSOCIATED_BUSIF [get_property CONFIG.ASSOCIATED_BUSIF [get_bd_ports /$g_UART_CLK]]$g_UART_ifname: [get_bd_ports /$g_UART_CLK]
	
	### UART memory map	
	
	set UARTbaseAddr [dict get $UARTentry BaseAddr]
	# set UARTMemRange [expr {2**$UARTaddrWidth/1024}]
	
	putdebugs "UARTBaseAddr $UARTbaseAddr"
	# putdebugs "UARTMemRange $UARTMemRange"
	# putdebugs "UARTaddrWidth $UARTaddrWidth"

	save_bd_design

	assign_bd_address [get_bd_addr_segs {$UartCoreName/S_AXI/Reg }]
	# set_property range ${UARTMemRange}K [get_bd_addr_segs ${g_UART_ifname}/SEG_${UartCoreName}_Reg]
	set_property offset $UARTbaseAddr   [get_bd_addr_segs ${g_UART_ifname}/SEG_${UartCoreName}_Reg]

}

putmeeps "UART is configured in $g_UART_MODE mode"
