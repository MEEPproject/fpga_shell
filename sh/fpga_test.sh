#!/bin/bash

OUTPUT_FILE=$1

stty -F /dev/ttyUSB2 115200 raw -echo
cat < /dev/ttyUSB2 > $OUTPUT_FILE &

echo "Sleep 5 minutes to let the UART output to be copied into the $OUTPUT_FILE file ..."

for i in 1 2 3 4 5
do
	sleep 60
	tail $OUTPUT_FILE
	echo "Wait 1 minute for the next output ($i/5)..."
done

echo "Kill cat process ..."

{ 
	sudo pkill cat 2> $OUTPUT_FILE.error 
} || { 
	echo "pkill cat command failed:"
	cat $OUTPUT_FILE.error || ls
}

echo "FPGA Test completed."

ls -l $OUTPUT_FILE

