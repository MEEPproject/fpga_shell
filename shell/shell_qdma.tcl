# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Solderpad Hardware License v 2.1 (the "License");
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
# 
#     http://www.solderpad.org/licenses/SHL-2.1
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Daniel J.Mazure, BSC-CNS
# Date: 22.02.2022
# Description: 

set PCIEifname [dict get $PCIEentry IntfLabel]
set PCIeDMA    [dict get $PCIEentry Mode]
set PCIeClkNm  [dict get $PCIEentry ClkName]
set PCIeRstNm  [dict get $PCIEentry RstName]
set PCIeJTAG   [dict get $PCIEentry JtagDebEn]
set PCIeHBMCh  [dict get $PCIEentry HBMChan]

set PortList [lappend PortList $g_pcie_file] 
  
  set pci_express_x16 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pci_express_x16 ]

  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]

   
  set pcie_perstn [ create_bd_port -dir I -type rst pcie_perstn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pcie_perstn

 
  # Create instance: qdma_0, and set properties
  set qdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:qdma:4.0 qdma_0 ]
  set_property -dict [ list \
   CONFIG.MAILBOX_ENABLE {true} \
   CONFIG.PF0_SRIOV_CAP_INITIAL_VF {4} \
   CONFIG.PF1_MSIX_CAP_TABLE_SIZE_qdma {000} \
   CONFIG.PF1_SRIOV_CAP_INITIAL_VF {0} \
   CONFIG.PF1_SRIOV_FIRST_VF_OFFSET {0} \
   CONFIG.PF2_MSIX_CAP_TABLE_SIZE_qdma {000} \
   CONFIG.PF2_SRIOV_CAP_INITIAL_VF {0} \
   CONFIG.PF2_SRIOV_FIRST_VF_OFFSET {0} \
   CONFIG.PF3_MSIX_CAP_TABLE_SIZE_qdma {000} \
   CONFIG.PF3_SRIOV_CAP_INITIAL_VF {0} \
   CONFIG.PF3_SRIOV_FIRST_VF_OFFSET {0} \
   CONFIG.SRIOV_CAP_ENABLE {true} \
   CONFIG.SRIOV_FIRST_VF_OFFSET {4} \
   CONFIG.coreclk_freq {250} \
   CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} \
   CONFIG.axi_data_width {256_bit} \
   CONFIG.barlite_mb_pf0 {1} \
   CONFIG.barlite_mb_pf1 {0} \
   CONFIG.barlite_mb_pf2 {0} \
   CONFIG.barlite_mb_pf3 {0} \
   CONFIG.dma_intf_sel_qdma {AXI_MM} \
   CONFIG.en_axi_st_qdma {false} \
   CONFIG.flr_enable {true} \
   CONFIG.mode_selection {Advanced} \
   CONFIG.pcie_blk_locn ${pcieBlockLoc} \
   CONFIG.select_quad {GTY_Quad_227} \
   CONFIG.pf0_ari_enabled {true} \
   CONFIG.pf0_bar0_prefetchable_qdma {true} \
   CONFIG.pf0_bar2_prefetchable_qdma {true} \
   CONFIG.pf1_bar0_prefetchable_qdma {true} \
   CONFIG.pf1_bar2_prefetchable_qdma {true} \
   CONFIG.pf1_msix_enabled_qdma {false} \
   CONFIG.pf2_bar0_prefetchable_qdma {true} \
   CONFIG.pf2_bar2_prefetchable_qdma {true} \
   CONFIG.pf2_msix_enabled_qdma {false} \
   CONFIG.pf3_bar0_prefetchable_qdma {true} \
   CONFIG.pf3_bar2_prefetchable_qdma {true} \
   CONFIG.pf3_msix_enabled_qdma {false} \
   CONFIG.pl_link_cap_max_link_width {X16} \
   CONFIG.testname {mm} \
   CONFIG.tl_pf_enable_reg {1} \
 ] $qdma_0

 # Disable AXI Lite interface

 set_property -dict [list CONFIG.axilite_master_en {false}] $qdma_0


 # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv $meep_util_ds_buf util_ds_buf ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $util_ds_buf

 
  # Create instance: vdd_0, and set properties (tie to vdd ready pcie signal)
  set vdd_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 vdd_0 ]
  
    # Create interface connections
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  #connect_bd_intf_net -intf_net qdma_0_M_AXI_LITE [get_bd_intf_pins axi_periph/S00_AXI] [get_bd_intf_pins qdma_0/M_AXI_LITE]
  connect_bd_intf_net -intf_net qdma_0_pcie_mgt [get_bd_intf_ports pci_express_x16] [get_bd_intf_pins qdma_0/pcie_mgt]
  connect_bd_net -net pcie_perstn_1 [get_bd_ports pcie_perstn] [get_bd_pins qdma_0/soft_reset_n] [get_bd_pins qdma_0/sys_rst_n]
 # connect_bd_net -net resetn_1 [get_bd_ports resetn] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins rst_dvino_alveo_300M/ext_reset_in]
  connect_bd_net -net vdd_0_dout [get_bd_pins qdma_0/qsts_out_rdy] [get_bd_pins qdma_0/tm_dsc_sts_rdy] [get_bd_pins vdd_0/dout]
  connect_bd_net -net util_ds_buf_IBUF_DS_ODIV2 [get_bd_pins qdma_0/sys_clk] [get_bd_pins util_ds_buf/IBUF_DS_ODIV2]
  connect_bd_net -net util_ds_buf_IBUF_OUT [get_bd_pins qdma_0/sys_clk_gt] [get_bd_pins util_ds_buf/IBUF_OUT]

  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_rst_pcie

  connect_bd_net [get_bd_pins qdma_0/axi_aclk] [get_bd_pins proc_sys_rst_pcie/slowest_sync_clk]
connect_bd_net [get_bd_pins qdma_0/phy_ready] [get_bd_pins proc_sys_rst_pcie/dcm_locked]
connect_bd_net [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins proc_sys_rst_pcie/ext_reset_in]



   if { $PCIeDMA != "dma" } {

 	  # AXI interface exposed to the EA, along the pcie_axi_clk and the reset signal
	   make_bd_intf_pins_external  [get_bd_intf_pins qdma_0/M_AXI]
	   set_property name $PCIEifname [get_bd_intf_ports M_AXI_0]
	   #Clock and reset
	   make_bd_pins_external  [get_bd_pins qdma_0/axi_aclk]
	   make_bd_pins_external  [get_bd_pins qdma_0/axi_aresetn]

	   set_property name $PCIeClkNm [get_bd_ports axi_aclk_0]
	   set_property name $PCIeRstNm [get_bd_ports axi_aresetn_0]
	   #TODO: Add register slice option to relax timing
   }

	# This variable is used in shell_hbm.tcl
	set PCIeDMAdone 0

set pcie_clk_pin [get_bd_pins qdma_0/axi_aclk]
set pcie_rst_pin [get_bd_pins proc_sys_rst_pcie/peripheral_aresetn]

set pcie_xbar_rst_pin [get_bd_pins proc_sys_rst_pcie/interconnect_aresetn]

################################################################
# PCIe-JTAG debugger
################################################################
 if { $PCIeJTAG == true } {

  set_property -dict [list CONFIG.cfg_ext_if {true}] $qdma_0
  set debug_bridge [create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 debug_bridge_0]
  set_property -dict [list CONFIG.C_DEBUG_MODE {6} CONFIG.C_PCIE_EXT_CFG_BASE_ADDR {0xe80}] $debug_bridge
  connect_bd_net [get_bd_pins debug_bridge_0/clk] $pcie_clk_pin
  connect_bd_intf_net [get_bd_intf_pins qdma_0/pcie_cfg_ext] [get_bd_intf_pins debug_bridge_0/pcie3_cfg_ext]
  make_bd_pins_external  [get_bd_pins debug_bridge_0/tap_tms] [get_bd_pins debug_bridge_0/tap_tck] [get_bd_pins debug_bridge_0/tap_tdi] [get_bd_pins debug_bridge_0/tap_tdo]
  set_property name jtag_tdo [get_bd_ports tap_tdo_0]
  set_property name jtag_tms [get_bd_ports tap_tms_0]
  set_property name jtag_tck [get_bd_ports tap_tck_0]
  set_property name jtag_tdi [get_bd_ports tap_tdi_0]

 }


################################################################
# QDMA Memory Map interface + BROM with system information
################################################################

# Create an interconnect for the PCIe AXI Lite interface
set axi_xbar_pcie_cell [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_xbar_pcie]
connect_bd_intf_net [get_bd_intf_pins qdma_0/M_AXI] -boundary_type upper [get_bd_intf_pins axi_xbar_pcie/S00_AXI]
connect_bd_net $pcie_clk_pin [get_bd_pins axi_xbar_pcie/ACLK]
connect_bd_net $pcie_xbar_rst_pin [get_bd_pins axi_xbar_pcie/ARESETN]
connect_bd_net $pcie_rst_pin [get_bd_pins axi_xbar_pcie/S00_ARESETN]
connect_bd_net $pcie_clk_pin [get_bd_pins axi_xbar_pcie/S00_ACLK]
set_property -dict [list CONFIG.NUM_MI {1}] $axi_xbar_pcie_cell
set_property -dict [list CONFIG.S00_HAS_REGSLICE {4}] $axi_xbar_pcie_cell
connect_bd_net [get_bd_pins axi_xbar_pcie/M00_ACLK] $pcie_clk_pin
connect_bd_net [get_bd_pins axi_xbar_pcie/M00_ARESETN] $pcie_rst_pin
# There is at least a BROM connected to the PCIe AXI LIte interface
set slv_axi_ninstances 1

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_brom_system
set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.SINGLE_PORT_BRAM {1} CONFIG.READ_LATENCY {8}] [get_bd_cells axi_brom_system]

### Initialize the ROM IP
putmeeps "Packaging ROM IP..."
exec make -C "$g_root_dir/ip/axi_brom" FPGA_BOARD=$g_board_part meep_rom
putmeeps "... Done."
update_ip_catalog -rebuild
# Place the initrom.mem file at $g_root_dir/ip/axi_brom/src

create_bd_cell -type ip -vlnv meep-project.eu:MEEP:native_bram:0.2 meep_rom
# 8K is the minimum to not to have issues
set_property -dict [list CONFIG.BRAM_ADDR_WIDTH {13}] [get_bd_cells meep_rom]


connect_bd_net [get_bd_pins axi_brom_system/bram_addr_a] [get_bd_pins meep_rom/addra]
connect_bd_net [get_bd_pins axi_brom_system/bram_clk_a] [get_bd_pins meep_rom/clka]
connect_bd_net [get_bd_pins axi_brom_system/bram_wrdata_a] [get_bd_pins meep_rom/dina]
connect_bd_net [get_bd_pins axi_brom_system/bram_rddata_a] [get_bd_pins meep_rom/douta]
connect_bd_net [get_bd_pins axi_brom_system/bram_en_a] [get_bd_pins meep_rom/ena]
connect_bd_net [get_bd_pins axi_brom_system/bram_we_a] [get_bd_pins meep_rom/wea]

connect_bd_net [get_bd_pins axi_brom_system/s_axi_aclk]  $pcie_clk_pin
connect_bd_net [get_bd_pins axi_brom_system/s_axi_aresetn]  $pcie_rst_pin

connect_bd_intf_net [get_bd_intf_pins axi_brom_system/S_AXI] -boundary_type upper [get_bd_intf_pins axi_xbar_pcie/M00_AXI]

# Crete hierarchy to beautify this block
group_bd_cells SHELL_ROM [get_bd_cells meep_rom] [get_bd_cells axi_brom_system]

save_bd_design
