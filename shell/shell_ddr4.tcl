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


putwarnings $DDR4entry

set DDR4Freq   [dict get $DDR4entry SyncClk Freq]
set DDR4name   [dict get $DDR4entry SyncClk Name]
set DDR4intf   [dict get $DDR4entry IntfLabel]
set DDR4Ready  [dict get $DDR4entry CalibDone]
set DDR4ChNum  [dict get $DDR4entry EnChannel]
set DDR4ClkNm  [dict get $DDR4entry ClkName]

set DDR4addrWidth [dict get $DDR4entry AxiAddrWidth]
set DDR4dataWidth [dict get $DDR4entry AxiDataWidth]
set DDR4idWidth   [dict get $DDR4entry AxiIdWidth]
set DDR4userWidth [dict get $DDR4entry AxiUserWidth]
## CAUTION: Axi user signals are not supported as input to the protocol 
## converter to DDR4. Hardcoded to 0
set DDR4userWidth 0

set PortList [lappend PortList $g_ddr4_file]


putmeeps "Creating DDR4 instance..."
### TODO: Region, prot and others can be extracted as the other widths
set ddr4_axi4 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $DDR4intf ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH $DDR4addrWidth \
   CONFIG.ARUSER_WIDTH $DDR4userWidth \
   CONFIG.AWUSER_WIDTH $DDR4userWidth \
   CONFIG.BUSER_WIDTH $DDR4userWidth \
   CONFIG.DATA_WIDTH $DDR4dataWidth \
   CONFIG.FREQ_HZ $DDR4Freq \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH $DDR4idWidth \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH $DDR4userWidth \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH $DDR4userWidth \
   ] $ddr4_axi4


  set ddr_dev ddr4_${DDR4ChNum}
	
  # Create instance: ddr4_0, and set properties
  set ddr4_inst [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 $ddr_dev ]
  set_property -dict [ list \
   CONFIG.C0.DDR4_AxiAddressWidth {34} \
   CONFIG.C0.DDR4_AxiDataWidth {512} \
   CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} \
   CONFIG.C0.DDR4_CasLatency {17} \
   CONFIG.C0.DDR4_CasWriteLatency {12} \
   CONFIG.C0.DDR4_DataMask {NONE} \
   CONFIG.C0.DDR4_DataWidth {72} \
   CONFIG.C0.DDR4_EN_PARITY {true} \
   CONFIG.C0.DDR4_Ecc {true} \
   CONFIG.C0.DDR4_InputClockPeriod {3331} \
   CONFIG.C0.DDR4_MemoryPart {MTA18ASF2G72PZ-2G3} \
   CONFIG.C0.DDR4_MemoryType {RDIMMs} \
   CONFIG.C0.DDR4_TimePeriod {833} \
   CONFIG.C0.DDR4_Mem_Add_Map {ROW_COLUMN_BANK_INTLV} \
   CONFIG.C0.DDR4_AUTO_AP_COL_A3 {true} \
 ] $ddr4_inst

set ddrUiClkPin [get_bd_pins ${ddr_dev}/c0_ddr4_ui_clk]

save_bd_design

# Input CLK
make_bd_intf_pins_external  [get_bd_intf_pins ${ddr_dev}/C0_SYS_CLK]
set_property name sysclk${DDR4ChNum} [get_bd_intf_ports C0_SYS_CLK_0]
set_property CONFIG.FREQ_HZ $FREQ_HZ [get_bd_intf_ports /sysclk${DDR4ChNum}]


#DDR io interface
make_bd_intf_pins_external  [get_bd_intf_pins ${ddr_dev}/C0_DDR4]
set_property name ddr4_sdram_c${DDR4ChNum} [get_bd_intf_ports C0_DDR4_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_pcie2ddr
set_property -dict [list CONFIG.NUM_SI {2} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_pcie2ddr]


# Clocks
connect_bd_net $ddrUiClkPin  [get_bd_pins axi_interconnect_pcie2ddr/ACLK]
connect_bd_net $ddrUiClkPin  [get_bd_pins axi_interconnect_pcie2ddr/M00_ACLK]
connect_bd_net $pcie_clk_pin [get_bd_pins axi_interconnect_pcie2ddr/S00_ACLK]
connect_bd_net $pcie_rst_pin [get_bd_pins axi_interconnect_pcie2ddr/S00_ARESETN]



connect_bd_intf_net [get_bd_intf_pins qdma_0/M_AXI] [get_bd_intf_pins axi_interconnect_pcie2ddr/S00_AXI]
connect_bd_intf_net [get_bd_intf_ports $DDR4intf] [get_bd_intf_pins axi_interconnect_pcie2ddr/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_pcie2ddr/M00_AXI] [get_bd_intf_pins ddr4_${DDR4ChNum}/C0_DDR4_S_AXI]
connect_bd_net [get_bd_pins axi_interconnect_pcie2ddr/S01_ACLK] [get_bd_pins ddr4_${DDR4ChNum}/c0_ddr4_ui_clk]


create_bd_port -dir O -type clk c0_ddr4_ui_clk
connect_bd_net $ddrUiClkPin [get_bd_ports c0_ddr4_ui_clk]

set_property name $DDR4ClkNm [get_bd_ports c0_ddr4_ui_clk]

# IMPORTANT: GET the UI clock frequency to propagate its value to the incoming associated AXI interface (generally, mem_axi4)
# set intfFreq [get_property CONFIG.FREQ_HZ [get_bd_pins $ddrUiClkPin]]
# set_property CONFIG.FREQ_HZ $intfFreq [get_bd_intf_ports /sysclk${DDR4ChNum}]
# Connnect the DDR4 AXI Lite interface to the same PCIe interconnect.

# Resets

#connect_bd_net [get_bd_pins ddr4_${DDR4ChNum}/c0_init_calib_complete] [get_bd_pins axi_interconnect_pcie2ddr/ARESETN]
set ddrResetBlock proc_sys_reset_ddr_${DDR4ChNum}
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 $ddrResetBlock

connect_bd_net [get_bd_pins ddr4_${DDR4ChNum}/c0_ddr4_ui_clk] [get_bd_pins $ddrResetBlock/slowest_sync_clk]
connect_bd_net [get_bd_pins $ddrResetBlock/peripheral_aresetn] [get_bd_pins ddr4_${DDR4ChNum}/c0_ddr4_aresetn]
connect_bd_net [get_bd_pins $ddrResetBlock/interconnect_aresetn] [get_bd_pins axi_interconnect_pcie2ddr/ARESETN]
connect_bd_net [get_bd_pins $ddrResetBlock/peripheral_aresetn] [get_bd_pins axi_interconnect_pcie2ddr/M00_ARESETN]

make_bd_pins_external  [get_bd_pins ddr4_${DDR4ChNum}/c0_init_calib_complete]
set_property name $DDR4Ready [get_bd_ports c0_init_calib_complete_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_ddrRst
set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {not} CONFIG.LOGO_FILE {data/sym_notgate.png}] [get_bd_cells util_vector_logic_ddrRst]
connect_bd_net [get_bd_ports resetn] [get_bd_pins util_vector_logic_ddrRst/Op1]
connect_bd_net [get_bd_pins util_vector_logic_ddrRst/Res] [get_bd_pins ddr4_${DDR4ChNum}/sys_rst]
connect_bd_net [get_bd_pins axi_interconnect_pcie2ddr/S01_ARESETN] [get_bd_pins ${ddrResetBlock}/peripheral_aresetn]
connect_bd_net [get_bd_ports resetn] [get_bd_pins ${ddrResetBlock}/ext_reset_in]

# Workaround to the uneeded AXIL DDR ctrl
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_${DDR4ChNum}/C0_DDR4_S_AXI_CTRL]

# Create the HBM cattrip ground connection
set hbm_cattrip [ create_bd_port -dir O -from 0 -to 0 hbm_cattrip ]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gnd_cattrip
set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells gnd_cattrip]
connect_bd_net [get_bd_ports hbm_cattrip] [get_bd_pins gnd_cattrip/dout]

save_bd_design

