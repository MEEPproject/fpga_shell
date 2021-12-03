set BROMClkNm [dict get $BROMentry SyncClk Label]
set BROMFreq  [dict get $BROMentry SyncClk Freq]
set BROMname  [dict get $BROMentry SyncClk Name]
set BROMintf  [dict get $BROMentry IntfLabel]
set BROMinitfile [dict get $BROMentry InitFile]

set BROMaddrWidth [dict get $BROMentry AxiAddrWidth]
set BROMdataWidth [dict get $BROMentry AxiDataWidth]
set BROMidWidth   [dict get $BROMentry AxiIdWidth]



set initFilePath $g_accel_dir/meep_shell/binaries/$BROMinitfile

#This needs to be extracted from the definition file, not set here would be needed
if { [file exists $initFilePath] == 1} {               
	file copy -force $initFilePath $meep_dir/ip/axi_brom/src/initrom.mem
	puts " BROM init file copied!"
} else {
	puts " BROM init file hasn't been provided!"
	puts " Consider to create it under EA/$initFilePath folder \r\n"
	#puts " Defaults to "
	#file copy -force $initFilePath $meep_dir/accelerator/meep_shell/binaries/$initBromFile
}
source $meep_dir/ip/axi_brom/tcl/gen_project.tcl
}


source $g_root_dir/ip/axi_brom/tcl/project_options.tcl
create_bd_cell -type ip -vlnv meep-project.eu:MEEP:axi_brom:$g_ip_version axi_brom_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0
set_property -dict [list CONFIG.DATA_WIDTH $BROMdataWidth CONFIG.SINGLE_PORT_BRAM {1} \
CONFIG.ECC_TYPE {0}] [get_bd_cells axi_bram_ctrl_0]

## Create the Shell interface to the RTL

  # Create interface ports
  set brom_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 brom_axi ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH $BROMaddrWidth \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH $BROMdataWidth \
   CONFIG.FREQ_HZ $BROMFreq \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH $BROMidWidth \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $brom_axi

 connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins clk_wiz_1/$BROMClkNm]
 connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins rst_ea_$BROMClkNm/peripheral_aresetn]
 
 connect_bd_net [get_bd_pins axi_bram_ctrl_0/bram_addr_a] [get_bd_pins axi_brom_0/addra]
 connect_bd_net [get_bd_pins axi_bram_ctrl_0/bram_clk_a] [get_bd_pins axi_brom_0/clka]
 connect_bd_net [get_bd_pins axi_brom_0/dina] [get_bd_pins axi_bram_ctrl_0/bram_wrdata_a]
 connect_bd_net [get_bd_pins axi_brom_0/douta] [get_bd_pins axi_bram_ctrl_0/bram_rddata_a]
 connect_bd_net [get_bd_pins axi_bram_ctrl_0/bram_en_a] [get_bd_pins axi_brom_0/ena]
 connect_bd_net [get_bd_pins axi_bram_ctrl_0/bram_we_a] [get_bd_pins axi_brom_0/wea]

 set BROMMemRange [expr {2**$BROMaddrWidth/1024}]

 putdebugs "BROM Mem Range: $BROMMemRange"

 # set_property offset 0x00000000 [get_bd_addr_segs {brom_axi/SEG_axi_bram_ctrl_0_Mem0}]
 # set_property range 64K [get_bd_addr_segs {brom_axi/SEG_axi_bram_ctrl_0_Mem0}]

 connect_bd_intf_net [get_bd_intf_ports brom_axi] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]

