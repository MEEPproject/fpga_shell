source ./ip/axi_brom/tcl/project_options.tcl
create_bd_cell -type ip -vlnv meep-project.eu:MEEP:axi_brom:$g_ip_version axi_brom_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0
set_property -dict [list CONFIG.DATA_WIDTH {128} CONFIG.SINGLE_PORT_BRAM {1} CONFIG.ECC_TYPE {0}] [get_bd_cells axi_bram_ctrl_0]


 set_property -dict [list CONFIG.NUM_MI {2}] [get_bd_cells axi_interconnect_0]
 connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
 connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins clk_wiz_1/clk_out1]
 connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins rst_ea_domain/peripheral_aresetn]
 connect_bd_net [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins clk_wiz_1/clk_out1]
 connect_bd_net [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins rst_ea_domain/peripheral_aresetn]

connect_bd_net [get_bd_pins axi_bram_ctrl_0/bram_addr_a] [get_bd_pins axi_brom_0/addra]
connect_bd_net [get_bd_pins axi_bram_ctrl_0/bram_clk_a] [get_bd_pins axi_brom_0/clka]
connect_bd_net [get_bd_pins axi_brom_0/dina] [get_bd_pins axi_bram_ctrl_0/bram_wrdata_a]
connect_bd_net [get_bd_pins axi_brom_0/douta] [get_bd_pins axi_bram_ctrl_0/bram_rddata_a]
connect_bd_net [get_bd_pins axi_bram_ctrl_0/bram_en_a] [get_bd_pins axi_brom_0/ena]
connect_bd_net [get_bd_pins axi_bram_ctrl_0/bram_we_a] [get_bd_pins axi_brom_0/wea]

  # assign_bd_address [get_bd_addr_segs {axi_brom_0/S_AXI/reg0 }] 
  # set_property offset 0x0000000000000000 [get_bd_addr_segs {qdma_0/M_AXI/SEG_axi_brom_0_reg0}]
  # set_property range 64K [get_bd_addr_segs {qdma_0/M_AXI/SEG_axi_brom_0_reg0}]
  # set_property range 64K [get_bd_addr_segs {mem_nasti/SEG_axi_brom_0_reg0}]
  # set_property offset 0x000000000 [get_bd_addr_segs {mem_nasti/SEG_axi_brom_0_reg0}]
  # exclude_bd_addr_seg [get_bd_addr_segs qdma_0/M_AXI/SEG_axi_brom_0_reg0]
  
  
