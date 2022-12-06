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


### If no GPIO is defined, set default values
### that will be left unconnected

if { $GPIOList eq "" } {
	set NumGPIO 1   
	set IntfName  NotUsedGPIO
	set InitValue 0x0	
} else {
	set NumGPIO   [dict get $GPIOList Width]
	set IntfName  [dict get $GPIOList IntfLabel]
	set InitValue [dict get $GPIOList InitValue]
}

# First enable the AXI Lite interface in the qdma IP:

set_property -dict [list CONFIG.axilite_master_en {true}] $qdma_0

putdebugs "Calling to GPIO: $GPIOList"

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property -dict [list CONFIG.C_GPIO_WIDTH "$NumGPIO" CONFIG.C_ALL_OUTPUTS 1] [get_bd_cells axi_gpio_0]
make_bd_pins_external  [get_bd_pins axi_gpio_0/gpio_io_o]
set_property name $IntfName [get_bd_ports gpio_io_o_0]
set_property -dict [list CONFIG.C_DOUT_DEFAULT $InitValue] [get_bd_cells axi_gpio_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_xbar_pcie_lite
connect_bd_intf_net [get_bd_intf_pins qdma_0/M_AXI_LITE] -boundary_type upper [get_bd_intf_pins axi_xbar_pcie_lite/S00_AXI]
connect_bd_net $pcie_clk_pin [get_bd_pins axi_xbar_pcie_lite/ACLK]
connect_bd_net [get_bd_pins qdma_0/phy_ready] [get_bd_pins axi_xbar_pcie_lite/ARESETN]
connect_bd_net $pcie_rst_pin [get_bd_pins axi_xbar_pcie_lite/S00_ARESETN]
connect_bd_net $pcie_clk_pin [get_bd_pins axi_xbar_pcie_lite/S00_ACLK]
set_property -dict [list CONFIG.NUM_MI {1}] [get_bd_cells axi_xbar_pcie_lite]
connect_bd_net [get_bd_pins axi_xbar_pcie_lite/M00_ACLK] $pcie_clk_pin
connect_bd_net [get_bd_pins axi_xbar_pcie_lite/M00_ARESETN] $pcie_rst_pin


connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_xbar_pcie_lite/M00_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]

connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aclk] $pcie_clk_pin
connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aresetn] $pcie_rst_pin

# At some point it looked as a good idea to clock the GPIO to lower speed
#connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aclk] $APBClockPin
#connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aresetn] $APBRstPin


## Add timing constraints to the timing constrains file
## For the GPIO, we assume all outputs are used as asynchronous to the PCIe clock domain.
set gpio_out_pin    "meep_shell_inst/axi_gpio_0/U0/gpio_core_1/Not_Dual.gpio_Data_Out_reg*/C"
set gpio_out_constr "set_false_path -from \[get_pins $gpio_out_pin\] "

set ConstrList [list $gpio_out_constr  ]

[Add2ConstrFileList $TimingConstrFile $ConstrList]

save_bd_design