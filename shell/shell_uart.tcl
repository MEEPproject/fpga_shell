#uart_rxd/txd could be renamed depending on the uart interface name passed on def.txt

set g_UART_MODE   [dict get $UARTentry Mode]
set g_UART_ifname [dict get $UARTentry IntfLabel]
set g_UART_irq    [dict get $UARTentry IRQ]
set g_UART_CLK	  [dict get $UARTentry SyncClk Name]
set g_CLK0_freq   [dict get $UARTentry SyncClk Freq]
set g_UARTClkPort [dict get $UARTentry SyncClk Label]

set UARTaddrWidth [dict get $UARTentry AxiAddrWidth]

putdebugs "UART? $g_UART_CLK"

if { $g_UART_MODE eq "simple"} {

	create_bd_port -dir I -type data rs232_rxd
	create_bd_port -dir O -type data rs232_txd
	create_bd_port -dir O -type data ${g_UART_ifname}_rxd
	create_bd_port -dir I -type data ${g_UART_ifname}_txd
	connect_bd_net [get_bd_ports ${g_UART_ifname}_txd] [get_bd_ports rs232_txd]
	connect_bd_net [get_bd_ports rs232_rxd] [get_bd_ports ${g_UART_ifname}_rxd]
}

if { $g_UART_MODE eq "normal" } {

	create_bd_port -dir I -type data rs232_rxd
	create_bd_port -dir O -type data rs232_txd	
	create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_0
	connect_bd_net [get_bd_ports rs232_rxd] [get_bd_pins axi_uart16550_0/sin]
	connect_bd_net [get_bd_ports rs232_txd] [get_bd_pins axi_uart16550_0/sout]
	#make_bd_pins_external  [get_bd_pins axi_uart16550_0/ip2intc_irpt]
	connect_bd_net [get_bd_pins axi_uart16550_0/s_axi_aclk] [get_bd_pins clk_wiz_1/$g_UARTClkPort]
	#connect_bd_net [get_bd_pins rst_ea_domain/peripheral_aresetn] [get_bd_pins axi_uart16550_0/s_axi_aresetn]

	# TODO: Deal with no IRQ scenario with if

	make_bd_intf_pins_external  [get_bd_intf_pins axi_uart16550_0/S_AXI]
	set_property name $g_UART_ifname [get_bd_intf_ports S_AXI_0]
	set_property CONFIG.FREQ_HZ $g_CLK0_freq [get_bd_intf_ports /$g_UART_ifname]
	make_bd_pins_external  [get_bd_pins axi_uart16550_0/ip2intc_irpt]
	set_property name $g_UART_irq [get_bd_ports ip2intc_irpt_0]
	set_property CONFIG.ASSOCIATED_BUSIF ${g_UART_ifname} [get_bd_ports /$g_UART_CLK]
	#exclude_bd_addr_seg [get_bd_addr_segs axi_uart16550_0/S_AXI/Reg] -target_address_space [get_bd_addr_spaces $g_UART_ifname]
	### UART memory map
	set UARTbaseAddr [dict get $UARTentry BaseAddr]
	set UARTMemRange [expr {2**$UARTaddrWidth/1024}]

	assign_bd_address [get_bd_addr_segs {axi_uart16550_0/S_AXI/Reg }]
	set_property range ${UARTMemRange}K [get_bd_addr_segs {io_nasti_uart/SEG_axi_uart16550_0_Reg}]
	set_property offset $UARTbaseAddr [get_bd_addr_segs {io_nasti_uart/SEG_axi_uart16550_0_Reg}]

}

putmeeps "UART is configured in $g_UART_MODE mode"