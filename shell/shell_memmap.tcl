

if { $g_DDR4 eq "yes"} {

  assign_bd_address
  exclude_bd_addr_seg [get_bd_addr_segs qdma_0/M_AXI_LITE/SEG_ddr4_0_C0_REG]
  set_property range 2G [get_bd_addr_segs {mem_nasti/SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK}]
  set_property range 2G [get_bd_addr_segs {qdma_0/M_AXI/SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK}]
  set_property offset 0x080000000 [get_bd_addr_segs {mem_nasti/SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK}]
  set_property offset 0x0000000080000000 [get_bd_addr_segs {qdma_0/M_AXI/SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK}]
  #assign_bd_address [get_bd_addr_segs {axi_gpio_0/S_AXI/Reg }]
  set_property range 64K [get_bd_addr_segs {qdma_0/M_AXI_LITE/SEG_axi_gpio_0_Reg}]
  set_property offset 0x00000000 [get_bd_addr_segs {qdma_0/M_AXI_LITE/SEG_axi_gpio_0_Reg}]
  
	  if { $g_BROM eq "yes"} {

	  exclude_bd_addr_seg [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -target_address_space [get_bd_addr_spaces qdma_0/M_AXI]
	  assign_bd_address [get_bd_addr_segs {axi_bram_ctrl_0/S_AXI/Mem0 }]
	  set_property range 64K [get_bd_addr_segs {mem_nasti/SEG_axi_bram_ctrl_0_Mem0}]
	  set_property offset 0x000000000 [get_bd_addr_segs {mem_nasti/SEG_axi_bram_ctrl_0_Mem0}]

	  }
  
} elseif { $g_HBM eq "yes"} {
	
	  #GPIO
	  assign_bd_address [get_bd_addr_segs {axi_gpio_0/S_AXI/Reg }]
	  set_property offset 0x00000000 [get_bd_addr_segs {qdma_0/M_AXI_LITE/SEG_axi_gpio_0_Reg}]

  
	  if { $g_BROM eq "yes"} {
	  
	  #EA network
	  # Create address segments
	  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI_LITE] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
 	  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mem_nasti] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force

	  assign_bd_address
	  
	  # assign_bd_address -offset 0x80000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00/HBM_MEM08] -force
	  # assign_bd_address -offset 0x90000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00/HBM_MEM09] -force
	  # assign_bd_address -offset 0xA0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00/HBM_MEM10] -force
	  # assign_bd_address -offset 0xB0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00/HBM_MEM11] -force
	  # assign_bd_address -offset 0xC0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00/HBM_MEM12] -force
	  # assign_bd_address -offset 0xD0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00/HBM_MEM13] -force
	  # assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00/HBM_MEM14] -force
	  # assign_bd_address -offset 0xF0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00/HBM_MEM15] -force
	  # assign_bd_address -offset 0x80000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mem_nasti] [get_bd_addr_segs hbm_0/SAXI_04/HBM_MEM08] -force
	  # assign_bd_address -offset 0x90000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mem_nasti] [get_bd_addr_segs hbm_0/SAXI_04/HBM_MEM09] -force
	  # assign_bd_address -offset 0xA0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mem_nasti] [get_bd_addr_segs hbm_0/SAXI_04/HBM_MEM10] -force
	  # assign_bd_address -offset 0xB0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mem_nasti] [get_bd_addr_segs hbm_0/SAXI_04/HBM_MEM11] -force
	  # assign_bd_address -offset 0xC0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mem_nasti] [get_bd_addr_segs hbm_0/SAXI_04/HBM_MEM12] -force
	  # assign_bd_address -offset 0xD0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mem_nasti] [get_bd_addr_segs hbm_0/SAXI_04/HBM_MEM13] -force
	  # assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mem_nasti] [get_bd_addr_segs hbm_0/SAXI_04/HBM_MEM14] -force
	  # assign_bd_address -offset 0xF0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mem_nasti] [get_bd_addr_segs hbm_0/SAXI_04/HBM_MEM15] -force

	  

	  } else {
	  
	  assign_bd_address
	  
	  }

 
}
