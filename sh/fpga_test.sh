#!/bin/bash

OUTPUT_FILE=$1

cat /dev/ttyUSB2 115200 > $OUTPUT_FILE &
