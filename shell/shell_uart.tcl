#uart_rxd/txd could be renamed depending on the uart interface name passed on def.txt

if { $g_UART_MODE eq "simple"} {
create_bd_port -dir I -type data rs232_rxd
create_bd_port -dir O -type data rs232_txd
create_bd_port -dir O -type data ${g_UART_ifname}_rxd
create_bd_port -dir I -type data ${g_UART_ifname}_txd
connect_bd_net [get_bd_ports ${g_UART_ifname}_txd] [get_bd_ports rs232_txd]
connect_bd_net [get_bd_ports rs232_rxd] [get_bd_ports ${g_UART_ifname}_rxd]

}
