#!/bin/bash
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
# Date: 17.12.2022
# Description: Generate the basic file structure to get fpga-shell compatibility for a given EA

# File list to get compatibility:
# 1) accelerator_def.csv
# 2) accelerator_build.sh
# 3) accelerator_init.sh - should be removed in the future, it is not useful anymore, but needs to be present -
# 4) accelerator_mod.sv - a wrapper for the EA. It could be removed in the future, as long as the EA top module is parsed instead
# 5) tcl/project_options.tcl

ROOT_DIR=$1
ACC_DIR=$ROOT_DIR/accelerator/meep_shell

mkdir -p $ACC_DIR/tcl

echo "**** This file has been created automatically. This line must be removed ****
EANAME=my_ea
PCIE,yes,pcie_axi,1,PCIE_CLK,pcie_clk,pcie_rstn,dma,0
DDR4,no,mem_axi
HBM,yes,mem_axi,1,CLK1,0x0,mem_calib_complete,00			
HBM,yes,ncmem_axi,1,CLK1,0x0,mem_calib_complete,01
AURORA,no,raw,<name>			
UART,yes,uart_axi,1,CLK0,0x0,normal,uart_irq
ETHERNET,yes,eth_axi,1,CLK0,eth_axi_aclk,eth_axi_arstn,10Gb,eth_irq,qsfp1,hbm
BROM,no,sram_axi,1,CLK0,0x0,initFile.mem
BRAM,no,sram_axi,1,CLK0,0x0,none
CLK0,100000000,chipset_clk
CLK1,150000000,mc_clk,mc_rstn,LOW
CLK2,50000000,vpu_clk
GPIO,5,pcie_gpio,0x00
ARST,LOW,ExtArstn
" > $ACC_DIR/accelerator_def.csv

echo -e "# Use this script to initialize your EA\n" > $ACC_DIR/accelerator_build.sh
echo -e "# Use this script to initialize your submodules\n" > $ACC_DIR/accelerator_init.sh
echo -e "# git submodules update --init --recursive\n" >> $ACC_DIR/accelerator_init.sh
echo -e "\/\/ Use this file to store the EA's top module definition \n" > $ACC_DIR/accelerator_mod.sv
echo -e "# Use this script to add your files to the g_ea_flist tcl list. It will be read by Shell's tcl/gen_project.tcl script\n" > $ACC_DIR/tcl/project_options.tcl
