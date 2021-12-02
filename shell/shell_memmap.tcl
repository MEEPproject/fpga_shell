### Set Base Addresses to peripherals
#1.BROM
set BROMbaseAddr [dict get $BROMentry BaseAddr]
set BROMMemRange [expr {2**$BROMaddrWidth/1024}]

putdebugs "Base Addr BROM: $BROMbaseAddr"
putdebugs "Mem Range BROM: $BROMMemRange"

assign_bd_address [get_bd_addr_segs {axi_bram_ctrl_0/S_AXI/Mem0 }]

set_property offset $BROMbaseAddr [get_bd_addr_segs {brom_axi/SEG_axi_bram_ctrl_0_Mem0}]
set_property range ${BROMMemRange}K [get_bd_addr_segs {brom_axi/SEG_axi_bram_ctrl_0_Mem0}]

###2. UART
set UARTbaseAddr [dict get $UARTentry BaseAddr]
set UARTMemRange [expr {2**$UARTaddrWidth/1024}]

assign_bd_address [get_bd_addr_segs {axi_uart16550_0/S_AXI/Reg }]
set_property range ${UARTMemRange}K [get_bd_addr_segs {io_nasti_uart/SEG_axi_uart16550_0_Reg}]
set_property offset $UARTbaseAddr [get_bd_addr_segs {io_nasti_uart/SEG_axi_uart16550_0_Reg}]



### Others
assign_bd_address
#set_property offset 0x00000000 [get_bd_addr_segs {qdma_0/M_AXI_LITE/SEG_axi_gpio_0_Reg}]
validate_bd_design
save_bd_design