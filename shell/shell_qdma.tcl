  
  
  set pci_express_x16 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pci_express_x16 ]

  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]

   
  set pcie_perstn [ create_bd_port -dir I -type rst pcie_perstn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pcie_perstn
  set resetn [ create_bd_port -dir I -type rst resetn ]
  
  
  
  # Create instance: axi_interconnect_0, and set properties
  # XBAR_DATA_WIDTH may depend on HBM/DDR4
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.S01_HAS_REGSLICE {4} \
   CONFIG.SYNCHRONIZATION_STAGES {7} \
   CONFIG.XBAR_DATA_WIDTH {128} \
 ] $axi_interconnect_0
 
 
  # Create instance: qdma_0, and set properties
  set qdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:qdma:4.0 qdma_0 ]
  set_property -dict [ list \
   CONFIG.MAILBOX_ENABLE {false} \
   CONFIG.PCIE_BOARD_INTERFACE {pci_express_x16} \
   CONFIG.PF0_SRIOV_CAP_INITIAL_VF {0} \
   CONFIG.PF0_SRIOV_FIRST_VF_OFFSET {0} \
   CONFIG.PF1_SRIOV_CAP_INITIAL_VF {0} \
   CONFIG.PF2_SRIOV_CAP_INITIAL_VF {0} \
   CONFIG.PF3_SRIOV_CAP_INITIAL_VF {0} \
   CONFIG.SRIOV_CAP_ENABLE {false} \
   CONFIG.SRIOV_FIRST_VF_OFFSET {1} \
   CONFIG.SYS_RST_N_BOARD_INTERFACE {pcie_perstn} \
   CONFIG.barlite_mb_pf0 {0} \
   CONFIG.dma_intf_sel_qdma {AXI_MM} \
   CONFIG.flr_enable {false} \
   CONFIG.pf0_ari_enabled {false} \
   CONFIG.pf0_bar0_prefetchable_qdma {false} \
   CONFIG.pf0_bar2_prefetchable_qdma {false} \
   CONFIG.pf0_bar2_size_qdma {64} \
   CONFIG.pf0_pciebar2axibar_2 {0x0} \
   CONFIG.pf1_bar0_prefetchable_qdma {false} \
   CONFIG.pf1_bar2_prefetchable_qdma {false} \
   CONFIG.pf1_bar2_size_qdma {64} \
   CONFIG.pf2_bar0_prefetchable_qdma {false} \
   CONFIG.pf2_bar2_prefetchable_qdma {false} \
   CONFIG.pf2_bar2_size_qdma {64} \
   CONFIG.pf3_bar0_prefetchable_qdma {false} \
   CONFIG.pf3_bar2_prefetchable_qdma {false} \
   CONFIG.pf3_bar2_size_qdma {64} \
 ] $qdma_0
 
 
   # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf ]
  set_property -dict [ list \
   CONFIG.DIFF_CLK_IN_BOARD_INTERFACE {pcie_refclk} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $util_ds_buf
 
  # Create instance: vdd_0, and set properties (tie to vdd ready pcie signal)
  set vdd_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 vdd_0 ]
  
    # Create interface connections
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net qdma_0_M_AXI [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins qdma_0/M_AXI]
  #connect_bd_intf_net -intf_net qdma_0_M_AXI_LITE [get_bd_intf_pins axi_periph/S00_AXI] [get_bd_intf_pins qdma_0/M_AXI_LITE]
  connect_bd_intf_net -intf_net qdma_0_pcie_mgt [get_bd_intf_ports pci_express_x16] [get_bd_intf_pins qdma_0/pcie_mgt]
  connect_bd_net -net pcie_perstn_1 [get_bd_ports pcie_perstn] [get_bd_pins qdma_0/soft_reset_n] [get_bd_pins qdma_0/sys_rst_n]
 # connect_bd_net -net resetn_1 [get_bd_ports resetn] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins rst_dvino_alveo_300M/ext_reset_in]
  connect_bd_net [get_bd_pins qdma_0/axi_aclk] [get_bd_pins axi_interconnect_0/S00_ACLK]
  connect_bd_net [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins axi_interconnect_0/S00_ARESETN] 
  connect_bd_net -net vdd_0_dout [get_bd_pins qdma_0/qsts_out_rdy] [get_bd_pins qdma_0/tm_dsc_sts_rdy] [get_bd_pins vdd_0/dout]
  connect_bd_net -net util_ds_buf_IBUF_DS_ODIV2 [get_bd_pins qdma_0/sys_clk] [get_bd_pins util_ds_buf/IBUF_DS_ODIV2]
  connect_bd_net -net util_ds_buf_IBUF_OUT [get_bd_pins qdma_0/sys_clk_gt] [get_bd_pins util_ds_buf/IBUF_OUT]


  #Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
  set_property -dict [ list \
   CONFIG.CLK_IN1_BOARD_INTERFACE {sysclk1} \
   CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
   CONFIG.USE_BOARD_FLOW {true} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_1

  set_property -dict [list CONFIG.USE_LOCKED {true}] [get_bd_cells clk_wiz_1]
 
 
  set_property -dict [list CONFIG.CLK_IN1_BOARD_INTERFACE {sysclk1}] [get_bd_cells clk_wiz_1]
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {sysclk1 ( 100 MHz System differential clock1 ) } Manual_Source {Auto}}  [get_bd_intf_pins clk_wiz_1/CLK_IN1_D]
  # The frequency value should be passed as a parameter from the def.txt file, the name too
  set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} CONFIG.USE_LOCKED {true} CONFIG.MMCM_CLKOUT0_DIVIDE_F {24.000} CONFIG.CLKOUT1_JITTER {132.683}] [get_bd_cells clk_wiz_1]
  
  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ea_domain
  connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins rst_ea_domain/slowest_sync_clk]
  connect_bd_net [get_bd_ports resetn] [get_bd_pins rst_ea_domain/ext_reset_in]
  connect_bd_net [get_bd_pins rst_ea_domain/peripheral_aresetn] [get_bd_pins axi_interconnect_0/S01_ARESETN]
  connect_bd_net [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_ea_domain/dcm_locked]
  
  
  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $axi_interconnect_1
 
  connect_bd_intf_net -intf_net qdma_0_M_AXI_LITE [get_bd_intf_pins axi_interconnect_1/S00_AXI] [get_bd_intf_pins qdma_0/M_AXI_LITE]
  connect_bd_net [get_bd_pins qdma_0/axi_aclk] [get_bd_pins axi_interconnect_1/S00_ACLK]
  connect_bd_net [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins axi_interconnect_1/S00_ARESETN]

  






