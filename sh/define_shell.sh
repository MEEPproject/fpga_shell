#!/bin/bash
# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Daniel J.Mazure, BSC-CNS
# Date: 22.02.2022
# Description: 


#This could be done with a recursive loop which walks a list of interfaces

ROOT_DIR=$(pwd)
ACC_DEF=$ROOT_DIR/accelerator/meep_shell/accelerator_def.txt

DDR4="`grep -rn -m 1 $ACC_DEF -e 'DDR4' | awk -F ',' '$2 {print $2}'`"
DDR4_ifname="`grep -rn $ACC_DEF -e 'DDR4' | awk -F ',' '$3 {print $3}'`"

HBM="`grep -rn $ACC_DEF -e 'HBM' | awk -F ',' '$2 {print $2}'`"
HBM_ifname="`grep -rn $ACC_DEF -e 'HBM' | awk -F ',' '$3 {print $3}'`"


AURORA="`grep -rn $ACC_DEF -e 'AURORA' | awk -F ',' '$2 {print $2}'`"
AURORA_ifname="`grep -rn $ACC_DEF -e 'AURORA' | awk -F ',' '$4 {print $4}'`"

UART="`grep -rn $ACC_DEF -e 'UART' | awk -F ',' '$2 {print $2}'`"

ETHERNET="`grep -rn $ACC_DEF -e 'ETHERNET' | awk -F ',' '$2 {print $2}'`"
ETHERNET_ifname="`grep -rn $ACC_DEF -e 'ETHERNET' | awk -F ',' '$3 {print $3}'`"

AURORA_MODE="`grep -rn $ACC_DEF -e 'AURORA' | awk -F ',' '$3 {print $3}'`"
UART_MODE="`grep -rn $ACC_DEF -e 'UART' | awk -F ',' '$3 {print $3}'`"
UART_ifname="`grep -rn $ACC_DEF -e 'UART' | awk -F ',' '$4 {print $4}'`"
UART_irq="`grep -rn $ACC_DEF -e 'UART' | awk -F ',' '$5 {print $5}'`"

BROM="`grep -rn $ACC_DEF -e 'BROM' | awk -F ',' '$2 {print $2}'`"
BROM_initname="`grep -rn $ACC_DEF -e 'UART' | awk -F ',' '$3 {print $3}'`"

CLK0_ifname="`grep -rn $ACC_DEF -e 'CLK0' | awk -F ',' '$3 {print $3}'`"
CLK0_freq="`grep -rn $ACC_DEF -e 'CLK0' | awk -F ',' '$2 {print $2}'`"

RST0_ifname="`grep -rn $ACC_DEF -e 'RESET' | awk -F ',' '$3 {print $3}'`"

ENV_FILE=$ROOT_DIR/tcl/shell_env.tcl

echo "set g_DDR4 $DDR4"                    >  $ENV_FILE
echo "set g_DDR4_ifname $DDR4_ifname"      >> $ENV_FILE
echo "set g_HBM  $HBM"                     >> $ENV_FILE
echo "set g_HBM_ifname $HBM_ifname"        >> $ENV_FILE
echo "set g_AURORA $AURORA"                >> $ENV_FILE
echo "set g_AURORA_ifname $AURORA_ifname"  >> $ENV_FILE
echo "set g_UART $UART"                    >> $ENV_FILE
echo "set g_ETHERNET $ETHERNET"            >> $ENV_FILE
echo "set g_BROM $BROM"                    >> $ENV_FILE
echo ""				    	   >> $ENV_FILE
echo "set g_AURORA_MODE $AURORA_MODE"      >> $ENV_FILE
echo "set g_UART_MODE $UART_MODE"          >> $ENV_FILE
echo "set g_UART_ifname $UART_ifname" 	   >> $ENV_FILE
echo "set g_UART_irq $UART_irq" 	   >> $ENV_FILE
echo "set g_BROM_initname  $BROM_initname" >> $ENV_FILE
echo "set g_CLK0	 $CLK0_ifname"     >> $ENV_FILE
echo "set g_CLK0_freq $CLK0_freq"          >> $ENV_FILE
echo "set g_RST0     $RST0_ifname"         >> $ENV_FILE

echo "Shell enviroment file created on $ENV_FILE"
