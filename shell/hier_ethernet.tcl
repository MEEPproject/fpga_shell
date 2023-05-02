
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

  set ETHqsfp      [lindex $eth_ip 0]
  set g_ip_version [lindex $eth_ip 1]


  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 eth_dma_axi_lite

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_tx
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_rx
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_sg

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 ${ETHqsfp}_1x

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ${ETHqsfp}_refclk


  # Create pins
  create_bd_pin -dir O -from 1 -to 0 -type intr eth_dma_irq
  create_bd_pin -dir O -from 0 -to 0 -type rst tx_rstn
  create_bd_pin -dir O -from 0 -to 0 -type rst rx_rstn
  create_bd_pin -dir O -type clk eth_gt_user_clock
  create_bd_pin -dir I -type clk eth_dma_clk
  create_bd_pin -dir I -type rst eth_dma_arstn
  create_bd_pin -dir I -type clk init_clk
  create_bd_pin -dir I -type clk locked
  create_bd_pin -dir I -type rst eth_ext_rstn
  create_bd_pin -dir O ${ETHqsfp}_fs
  create_bd_pin -dir O ${ETHqsfp}_oe_b

  set EthIPName MEEP_10Gb_Ethernet_${ETHqsfp}

  create_bd_cell -type ip -vlnv meep-project.eu:MEEP:MEEP_10Gb_Ethernet_${ETHqsfp}:$g_ip_version $EthIPName

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_addr_width {40} \
   CONFIG.c_include_mm2s_dre {1} \
   CONFIG.c_include_s2mm_dre {1} \
   CONFIG.c_include_sg {1} \
   CONFIG.c_m_axi_mm2s_data_width {256} \
   CONFIG.c_m_axi_s2mm_data_width {256} \
   CONFIG.c_m_axis_mm2s_tdata_width {64} \
   CONFIG.c_mm2s_burst_size {128} \
   CONFIG.c_s2mm_burst_size {128} \
   CONFIG.c_s_axis_s2mm_tdata_width {64} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {22} \
 ] $axi_dma_0

  set dma_connect_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 dma_connect_tx ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $dma_connect_tx

  set dma_connect_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 dma_connect_rx ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $dma_connect_rx

  set dma_connect_sg [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 dma_connect_sg ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $dma_connect_sg

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $smartconnect_0

#create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dwidth_converter:2.1 axi_dwidth_converter_0
# TODO: Ideally, we will clock the AXI Lite DMA interface with an user clock, so we can use the external reset associated to that clock, and reduce the timing requirement for the ethernet logic in the EA.  

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_irq


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins eth_dma_axi_lite] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins smartconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net ${EthIPName}_ETH_RX_AXIS [get_bd_intf_pins ${EthIPName}/ETH_RX_AXIS] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net ${EthIPName}_qsfp_1x [get_bd_intf_pins ${ETHqsfp}_1x] [get_bd_intf_pins ${EthIPName}/qsfp_1x]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins ${EthIPName}/ETH_TX_AXIS] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins dma_connect_tx/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins dma_connect_rx/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_SG [get_bd_intf_pins axi_dma_0/M_AXI_SG] [get_bd_intf_pins dma_connect_sg/S00_AXI]
  connect_bd_intf_net [get_bd_intf_pins m_axi_tx] [get_bd_intf_pins dma_connect_tx/M00_AXI]
  connect_bd_intf_net [get_bd_intf_pins m_axi_rx] [get_bd_intf_pins dma_connect_rx/M00_AXI]
  connect_bd_intf_net [get_bd_intf_pins m_axi_sg] [get_bd_intf_pins dma_connect_sg/M00_AXI]
  connect_bd_intf_net -intf_net ${ETHqsfp}_refclk_1 [get_bd_intf_pins ${ETHqsfp}_refclk] [get_bd_intf_pins ${EthIPName}/qsfp_refclk]
  #
  save_bd_design

  # Create port connections
  connect_bd_net -net ${EthIPName}_qsfp_refclk_fs [get_bd_pins ${ETHqsfp}_fs] [get_bd_pins ${EthIPName}/qsfp_refclk_fs]
  connect_bd_net -net ${EthIPName}_qsfp_refclk_oe_b [get_bd_pins ${ETHqsfp}_oe_b] [get_bd_pins ${EthIPName}/qsfp_refclk_oe_b]
  connect_bd_net -net clock_1 [get_bd_pins init_clk] [get_bd_pins ${EthIPName}/init_clk]
  connect_bd_net -net clock_ok_1 [get_bd_pins locked] [get_bd_pins ${EthIPName}/locked]
  connect_bd_net -net ethernet_alveo_0_eth_gt_user_clock [get_bd_pins eth_gt_user_clock] [get_bd_pins ${EthIPName}/eth_gt_user_clock] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins dma_connect_tx/aclk] [get_bd_pins dma_connect_rx/aclk]

  connect_bd_net [get_bd_pins eth_dma_clk] [get_bd_pins smartconnect_0/aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_dma_0/m_axi_sg_aclk] [get_bd_pins dma_connect_sg/aclk]
  connect_bd_net [get_bd_pins eth_dma_arstn] [get_bd_pins smartconnect_0/aresetn] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins dma_connect_sg/aresetn]

  connect_bd_net [get_bd_pins axi_dma_0/mm2s_introut] [get_bd_pins xlconcat_irq/In0]
  connect_bd_net [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins xlconcat_irq/In1]

  connect_bd_net [get_bd_pins axi_dma_0/mm2s_prmry_reset_out_n] [get_bd_pins dma_connect_tx/aresetn] [get_bd_pins tx_rstn]
  connect_bd_net [get_bd_pins axi_dma_0/s2mm_prmry_reset_out_n] [get_bd_pins dma_connect_rx/aresetn] [get_bd_pins rx_rstn]

  connect_bd_net [get_bd_pins eth_dma_irq] [get_bd_pins xlconcat_irq/dout]


  # Restore current instance
  current_bd_instance $oldCurInst
}


