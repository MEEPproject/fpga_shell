
##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: Ethernet10Gb_qsfp0
proc create_hier_cell_Ethernet { parentCell nameHier eth_ip } {

  set parentObj [get_bd_cells $parentCell]
  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 eth_dma_axi_lite

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 eth_dma_m_axi

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp0_1x

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_refclk


  # Create pins
  create_bd_pin -dir O -from 1 -to 0 -type intr eth_dma_mm2s_intr
  create_bd_pin -dir O -from 1 -to 0 -type intr eth_dma_s2mm_intr
  create_bd_pin -dir O -from 0 -to 0 -type rst eth_gt_rstn
  create_bd_pin -dir O -type clk eth_gt_user_clock
  create_bd_pin -dir I -type clk init_clk
  create_bd_pin -dir O -type intr irq_dma_mm2s
  create_bd_pin -dir O -type intr irq_dma_s2mm
  create_bd_pin -dir I -type clk locked
  create_bd_pin -dir O qsfp0_fs
  create_bd_pin -dir O qsfp0_oe_b
  create_bd_pin -dir I -type clk sys_clk
  create_bd_pin -dir I -type rst sys_resetn

  set ETHqsfp      [lindex $eth_ip 0]
  set g_ip_version [lindex $eth_ip 1]

  set EthIPName MEEP_10Gb_Ethernet_${ETHqsfp}

  create_bd_cell -type ip -vlnv meep-project.eu:MEEP:MEEP_10Gb_Ethernet_${ETHqsfp}:$g_ip_version $EthIPName

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_addr_width {48} \
   CONFIG.c_include_mm2s_dre {1} \
   CONFIG.c_include_s2mm_dre {1} \
   CONFIG.c_m_axi_mm2s_data_width {512} \
   CONFIG.c_m_axi_s2mm_data_width {512} \
   CONFIG.c_m_axis_mm2s_tdata_width {64} \
   CONFIG.c_mm2s_burst_size {32} \
   CONFIG.c_s2mm_burst_size {32} \
   CONFIG.c_s_axis_s2mm_tdata_width {64} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {23} \
 ] $axi_dma_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {3} \
 ] $axi_interconnect_0

  # Create instance: proc_sys_reset_eth, and set properties
  set proc_sys_reset_eth [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_eth ]

  # Create interface connections
  connect_bd_intf_net -intf_net ETH_DMA_S_AXIL_1 [get_bd_intf_pins eth_dma_axi_lite] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net ${EthIPName}_ETH0_RX_AXIS [get_bd_intf_pins ${EthIPName}/ETH0_RX_AXIS] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net ${EthIPName}_qsfp_1x [get_bd_intf_pins qsfp0_1x] [get_bd_intf_pins ${EthIPName}/qsfp_1x]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins ${EthIPName}/ETH0_TX_AXIS] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins axi_interconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins axi_interconnect_0/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_SG [get_bd_intf_pins axi_dma_0/M_AXI_SG] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins eth_dma_m_axi] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net qsfp0_refclk_1 [get_bd_intf_pins qsfp0_refclk] [get_bd_intf_pins ${EthIPName}/qsfp_refclk]

  # Create port connections
  connect_bd_net -net ${EthIPName}_eth_gt_resetn [get_bd_pins ${EthIPName}/eth_gt_resetn] [get_bd_pins proc_sys_reset_eth/ext_reset_in]
  connect_bd_net -net ${EthIPName}_qsfp0_refclk_fs [get_bd_pins qsfp0_fs] [get_bd_pins ${EthIPName}/qsfp0_refclk_fs]
  connect_bd_net -net ${EthIPName}_qsfp0_refclk_oe_b [get_bd_pins qsfp0_oe_b] [get_bd_pins ${EthIPName}/qsfp0_refclk_oe_b]
  connect_bd_net -net axi_dma_0_mm2s_introut [get_bd_pins irq_dma_mm2s] [get_bd_pins axi_dma_0/mm2s_introut]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins irq_dma_s2mm] [get_bd_pins axi_dma_0/s2mm_introut]
  connect_bd_net -net axi_resetn_1 [get_bd_pins sys_resetn] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_interconnect_0/M00_ARESETN]
  connect_bd_net -net clock_1 [get_bd_pins init_clk] [get_bd_pins ${EthIPName}/init_clk]
  connect_bd_net -net clock_ok_1 [get_bd_pins locked] [get_bd_pins ${EthIPName}/locked]
  connect_bd_net -net ethernet_alveo_0_eth_gt_user_clock [get_bd_pins eth_gt_user_clock] [get_bd_pins ${EthIPName}/eth_gt_user_clock] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/m_axi_sg_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_0/S02_ACLK] [get_bd_pins proc_sys_reset_eth/slowest_sync_clk]
  connect_bd_net -net proc_sys_reset_eth_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins proc_sys_reset_eth/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_eth_peripheral_aresetn [get_bd_pins eth_gt_rstn] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_0/S02_ARESETN] [get_bd_pins proc_sys_reset_eth/peripheral_aresetn]
  connect_bd_net -net s_axi_lite_aclk_0_1 [get_bd_pins sys_clk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_interconnect_0/M00_ACLK]

  # Restore current instance
  current_bd_instance $oldCurInst
}


