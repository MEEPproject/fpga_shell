
   
  set hbm_cattrip [ create_bd_port -dir O -from 0 -to 0 hbm_cattrip ]
  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gnd_0
  set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells gnd_0]
  connect_bd_net [get_bd_ports hbm_cattrip] [get_bd_pins gnd_0/dout]
 
 
   
   # FREQ_HZ needs to be passed as a parameter from the def.txt file
  set ddr4_axi4 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 ddr4_axi4 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {1} \
   CONFIG.AWUSER_WIDTH {1} \
   CONFIG.BUSER_WIDTH {1} \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.FREQ_HZ {50000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {9} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {1} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {1} \
   ] $ddr4_axi4

  set ddr4_sdram_c0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 ddr4_sdram_c0 ]
  
  # Create instance: ddr4_0, and set properties
  set ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0 ]
  set_property -dict [ list \
   CONFIG.C0_CLOCK_BOARD_INTERFACE {Custom} \
   CONFIG.C0_DDR4_BOARD_INTERFACE {Custom} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.C0.DDR4_TimePeriod {833} \
   CONFIG.C0.DDR4_InputClockPeriod {9996} \
   CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} \
   CONFIG.C0.DDR4_MemoryType {RDIMMs} \
   CONFIG.C0.DDR4_MemoryPart {MTA18ASF2G72PZ-2G3} \
   CONFIG.C0.DDR4_DataWidth {72} \
   CONFIG.C0.DDR4_DataMask {NONE} \
   CONFIG.C0.DDR4_Ecc {true} \
   CONFIG.C0.DDR4_CasLatency {17} \
   CONFIG.C0.DDR4_CasWriteLatency {12} \
   CONFIG.C0.DDR4_AxiDataWidth {512} \
   CONFIG.C0.DDR4_AxiAddressWidth {34} \
   CONFIG.C0.DDR4_EN_PARITY {true} \
 ] $ddr4_0
 
 
 
 # # Insert AXI GPIO
 # create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
 # set_property -dict [list CONFIG.C_GPIO_WIDTH {1} CONFIG.C_ALL_OUTPUTS {1}] [get_bd_cells axi_gpio_0]
 # set_property -dict [list CONFIG.NUM_MI {2}] [get_bd_cells axi_interconnect_1]
 # connect_bd_net [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins qdma_0/axi_aclk]
 # connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins qdma_0/axi_aclk]
 # connect_bd_net [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins axi_interconnect_1/M01_ARESETN]
 # connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins qdma_0/axi_aresetn]
 # connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_1/M01_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]  
 # create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
 # set_property -dict [list CONFIG.NUM_PORTS {1}] [get_bd_cells xlconcat_0]
 # connect_bd_net [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins xlconcat_0/In0]
 # make_bd_pins_external  [get_bd_pins xlconcat_0/dout]
 # set_property name $g_RST0 [get_bd_ports dout_0]



 make_bd_intf_pins_external  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
 set_property name sysclk0 [get_bd_intf_ports C0_SYS_CLK_0]
 connect_bd_intf_net [get_bd_intf_ports ddr4_sdram_c0] [get_bd_intf_pins ddr4_0/C0_DDR4]

 create_bd_port -dir O -type clk clk_ddr4
 connect_bd_net [get_bd_ports clk_ddr4] [get_bd_pins clk_wiz_1/clk_out1]
 connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins axi_interconnect_0/S01_ACLK]


 
   # Create interface connections
  connect_bd_intf_net -intf_net ddr4_axi4_1 [get_bd_intf_ports ddr4_axi4] [get_bd_intf_pins axi_interconnect_0/S01_AXI]
  
  connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins axi_interconnect_0/ACLK]
  connect_bd_net [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins ddr4_0/c0_ddr4_ui_clk]
  connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]

  set rst_system_ddr [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_system_ddr ]
  connect_bd_net [get_bd_pins rst_system_ddr/slowest_sync_clk] [get_bd_pins ddr4_0/c0_ddr4_ui_clk]
  connect_bd_net [get_bd_ports resetn] [get_bd_pins rst_system_ddr/ext_reset_in]
  connect_bd_net [get_bd_pins rst_system_ddr/interconnect_aresetn] [get_bd_pins axi_interconnect_0/ARESETN]
  connect_bd_net [get_bd_pins rst_system_ddr/peripheral_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN]
  
  connect_bd_net [get_bd_pins rst_system_ddr/peripheral_aresetn] [get_bd_pins ddr4_0/c0_ddr4_aresetn]
  connect_bd_net [get_bd_pins rst_system_ddr/peripheral_reset] [get_bd_pins ddr4_0/sys_rst]
  
  connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_1/M00_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI_CTRL]

  connect_bd_net [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins ddr4_0/c0_ddr4_ui_clk]
  connect_bd_net [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins ddr4_0/c0_ddr4_ui_clk]
  connect_bd_net [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins rst_system_ddr/interconnect_aresetn]
  connect_bd_net [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins rst_system_ddr/peripheral_aresetn]
  

  # # Create address segments
  # assign_bd_address -offset 0x00000000 -range 0x000400000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  # assign_bd_address -offset 0x80000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI_LITE] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP_CTRL/C0_REG] -force
  # assign_bd_address -offset 0x00000000 -range 0x000400000000 -target_address_space [get_bd_addr_spaces ddr4_axi4] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force

  #Rename the interface to match def.txt EA fileset_property name mem_nasti [get_bd_intf_ports ddr4_axi4]
  set_property name $g_DDR4_ifname [get_bd_intf_ports ddr4_axi4]
  set_property name $g_CLK0 [get_bd_ports clk_ddr4]
  

  save_bd_design



