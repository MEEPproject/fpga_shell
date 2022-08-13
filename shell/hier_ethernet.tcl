
# Hierarchical cell: ETHERNET
proc create_hier_cell_ETHERNET { parentCell nameHier eth_ip} {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_ETHERNET() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 ETH_DMA_S_AXIL

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 ETH_LITE_S_AXIL

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 eth_dma2epac_m_axi

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp0_1x

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_refclk


  # Create pins
  create_bd_pin -dir O -from 0 -to 0 -type intr IRQ
  create_bd_pin -dir I -type clk epac_clk
  create_bd_pin -dir I -type rst epac_resetn
  create_bd_pin -dir O -from 1 -to 0 -type intr eth_dma_mm2s_intr
  create_bd_pin -dir O -from 1 -to 0 -type intr eth_dma_s2mm_intr
  create_bd_pin -dir O -from 0 -to 0 -type rst eth_gt_rstn
  create_bd_pin -dir O -type clk eth_gt_user_clock
  create_bd_pin -dir I -type clk init_clk
  create_bd_pin -dir I -type clk locked
  create_bd_pin -dir O qsfp0_fs
  create_bd_pin -dir O qsfp0_oe_b

  set ETHqsfp      [lindex $eth_ip 0]
  set g_ip_version [lindex $eth_ip 1]

  create_bd_cell -type ip -vlnv meep-project.eu:MEEP:MEEP_10Gb_Ethernet_${ETHqsfp}:$g_ip_version MEEP_10Gb_Ethernet_${ETHqsfp}

  set EthIPName MEEP_10Gb_Ethernet_${ETHqsfp}

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

  # Create instance: cdc_irq_dma_mm2s, and set properties
  set cdc_irq_dma_mm2s [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen:1.0 cdc_irq_dma_mm2s ]

  # Create instance: cdc_irq_dma_s2mm, and set properties
  set cdc_irq_dma_s2mm [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen:1.0 cdc_irq_dma_s2mm ]

  # Create instance: cdc_irq_mac, and set properties
  set cdc_irq_mac [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen:1.0 cdc_irq_mac ]
  set_property -dict [ list \
   CONFIG.WIDTH {1} \
 ] $cdc_irq_mac

  # Create instance: eth1g_intf_xlnx_axil_0, and set properties
  set eth1g_intf_xlnx_axil_0 [ create_bd_cell -type ip -vlnv FORTH:eth1g_intf_xlnx_axil_wrapper_top_lib:eth1g_intf_xlnx_axil_wrapper_top:1.0.0 eth1g_intf_xlnx_axil_0 ]

  # Create instance: eth_rx_axis_switch, and set properties
  set eth_rx_axis_switch [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 eth_rx_axis_switch ]
  set_property -dict [ list \
   CONFIG.DECODER_REG {1} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.NUM_MI {2} \
   CONFIG.NUM_SI {1} \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.TDEST_WIDTH {1} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {1} \
 ] $eth_rx_axis_switch

  # Create instance: eth_tx_axis_switch, and set properties
  set eth_tx_axis_switch [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 eth_tx_axis_switch ]
  set_property -dict [ list \
   CONFIG.ARB_ON_MAX_XFERS {1024} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
 ] $eth_tx_axis_switch

  # Create instance: proc_sys_reset_eth, and set properties
  set proc_sys_reset_eth [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_eth ]

  # Create interface connections
  connect_bd_intf_net -intf_net ${EthIPName}_ETH0_RX_AXIS [get_bd_intf_pins ${EthIPName}/ETH0_RX_AXIS] [get_bd_intf_pins eth_rx_axis_switch/S00_AXIS]
  connect_bd_intf_net -intf_net ${EthIPName}_qsfp_1x [get_bd_intf_pins qsfp0_1x] [get_bd_intf_pins ${EthIPName}/qsfp_1x]
  connect_bd_intf_net -intf_net ETH_DMA_S_AXIL_1 [get_bd_intf_pins ETH_DMA_S_AXIL] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net ETH_LITE_S_AXIL_1 [get_bd_intf_pins ETH_LITE_S_AXIL] [get_bd_intf_pins eth1g_intf_xlnx_axil_0/S_AXIL]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins eth_tx_axis_switch/S01_AXIS]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins axi_interconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins axi_interconnect_0/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_SG [get_bd_intf_pins axi_dma_0/M_AXI_SG] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins eth_dma2epac_m_axi] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net eth1g_intf_xlnx_axil_0_M_AXIS [get_bd_intf_pins eth1g_intf_xlnx_axil_0/M_AXIS] [get_bd_intf_pins eth_tx_axis_switch/S00_AXIS]
  connect_bd_intf_net -intf_net eth_rx_axis_switch_M00_AXIS [get_bd_intf_pins eth1g_intf_xlnx_axil_0/S_AXIS] [get_bd_intf_pins eth_rx_axis_switch/M00_AXIS]
  connect_bd_intf_net -intf_net eth_rx_axis_switch_M01_AXIS [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins eth_rx_axis_switch/M01_AXIS]
  connect_bd_intf_net -intf_net eth_tx_axis_switch_M00_AXIS [get_bd_intf_pins ${EthIPName}/ETH0_TX_AXIS] [get_bd_intf_pins eth_tx_axis_switch/M00_AXIS]
  connect_bd_intf_net -intf_net qsfp0_refclk_1 [get_bd_intf_pins qsfp0_refclk] [get_bd_intf_pins ${EthIPName}/qsfp_refclk]

  # Create port connections
  connect_bd_net -net ${EthIPName}_eth_gt_resetn [get_bd_pins ${EthIPName}/eth_gt_resetn] [get_bd_pins proc_sys_reset_eth/ext_reset_in]
  connect_bd_net -net ${EthIPName}_qsfp0_refclk_fs [get_bd_pins qsfp0_fs] [get_bd_pins ${EthIPName}/qsfp0_refclk_fs]
  connect_bd_net -net ${EthIPName}_qsfp0_refclk_oe_b [get_bd_pins qsfp0_oe_b] [get_bd_pins ${EthIPName}/qsfp0_refclk_oe_b]
  connect_bd_net -net axi_dma_0_mm2s_introut [get_bd_pins axi_dma_0/mm2s_introut] [get_bd_pins cdc_irq_dma_mm2s/src_in]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins cdc_irq_dma_s2mm/src_in]
  connect_bd_net -net axi_resetn_1 [get_bd_pins epac_resetn] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_interconnect_0/M00_ARESETN]
  connect_bd_net -net cdc_irq_dma_mm2s_dest_out [get_bd_pins eth_dma_mm2s_intr] [get_bd_pins cdc_irq_dma_mm2s/dest_out]
  connect_bd_net -net cdc_irq_dma_s2mm_dest_out [get_bd_pins eth_dma_s2mm_intr] [get_bd_pins cdc_irq_dma_s2mm/dest_out]
  connect_bd_net -net clock_1 [get_bd_pins init_clk] [get_bd_pins ${EthIPName}/init_clk]
  connect_bd_net -net clock_ok_1 [get_bd_pins locked] [get_bd_pins ${EthIPName}/locked]
  connect_bd_net -net eth1g_intf_xlnx_axil_0_IRQ [get_bd_pins cdc_irq_mac/src_in] [get_bd_pins eth1g_intf_xlnx_axil_0/IRQ]
  connect_bd_net -net ethernet_alveo_0_eth_gt_user_clock [get_bd_pins eth_gt_user_clock] [get_bd_pins ${EthIPName}/eth_gt_user_clock] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/m_axi_sg_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_0/S02_ACLK] [get_bd_pins cdc_irq_dma_mm2s/src_clk] [get_bd_pins cdc_irq_dma_s2mm/src_clk] [get_bd_pins cdc_irq_mac/src_clk] [get_bd_pins eth1g_intf_xlnx_axil_0/S_AXIL_CLK] [get_bd_pins eth_rx_axis_switch/aclk] [get_bd_pins eth_tx_axis_switch/aclk] [get_bd_pins proc_sys_reset_eth/slowest_sync_clk]
  connect_bd_net -net proc_sys_reset_eth_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins proc_sys_reset_eth/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_eth_peripheral_aresetn [get_bd_pins eth_gt_rstn] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_0/S02_ARESETN] [get_bd_pins eth1g_intf_xlnx_axil_0/S_AXIL_ARESETN] [get_bd_pins eth_rx_axis_switch/aresetn] [get_bd_pins eth_tx_axis_switch/aresetn] [get_bd_pins proc_sys_reset_eth/peripheral_aresetn]
  connect_bd_net -net s_axi_lite_aclk_0_1 [get_bd_pins epac_clk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins cdc_irq_dma_mm2s/dest_clk] [get_bd_pins cdc_irq_dma_s2mm/dest_clk] [get_bd_pins cdc_irq_mac/dest_clk]
  connect_bd_net -net xpm_cdc_irq_mac_dest_out [get_bd_pins IRQ] [get_bd_pins cdc_irq_mac/dest_out]

  # Restore current instance
  current_bd_instance $oldCurInst
}

