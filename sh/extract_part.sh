#!/bin/bash

ENV_FILE="tcl/environment.tcl"
FPGA_PART="g_fpga_part"
FPGA_BOARD="g_board_part"

FPGA_BOARD_NAME=$1
FPGA_PART_NAME=$2

FPGA_BOARD_COMMAND="$FPGA_BOARD $FPGA_BOARD_NAME"


#Substitue the entire line where a match to $FPGA_BOARD has been found thanks to .* after the matching
#string. If .* is not present, only the matching string gets substitued.

sed -i "0,/$FPGA_BOARD/{s|$FPGA_BOARD.*|$FPGA_BOARD_COMMAND|}" $ENV_FILE

if [ -n "$FPGA_PART_NAME" ]; then
  FPGA_PART_COMMAND="$FPGA_PART $FPGA_PART_NAME"
  #Do the same process for the FPGA PART if the parameters has been passed
  sed -i "0,/$FPGA_PART/{s|$FPGA_PART.*|$FPGA_PART_COMMAND|}" $ENV_FILE

fi

