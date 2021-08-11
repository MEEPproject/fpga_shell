#!/bin/bash

ENV_FILE="tcl/environment.tcl"
FPGA_PART="g_fpga_part"
FPGA_BOARD="g_board_part"

FPGA_PART_NAME=$1
FPGA_BOARD_NAME=$2

FPGA_PART_COMMAND="$FPGA_PART $FPGA_PART_NAME"
FPGA_BOARD_COMMAND="$FPGA_BOARD $FPGA_BOARD_NAME"

#Substitue the entire line where a match to $FPGA_PART has been found thanks to .* after the matching 
#string. If .* is not present, only the matching string gets substitued.
sed -i "0,/$FPGA_PART/{s|$FPGA_PART.*|$FPGA_PART_COMMAND|}" $ENV_FILE

#Do the same process for the FPGA BOARD
sed -i "0,/$FPGA_BOARD/{s|$FPGA_BOARD.*|$FPGA_BOARD_COMMAND|}" $ENV_FILE


