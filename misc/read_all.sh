#!/bin/bash

ADDR=0x400000000

function read_next {
  ADDR=$(($ADDR + 4))  
  ./read.sh "$ADDR"
}

cat title.txt

printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
printf " ║ %-30s  ║ %s   ║\n" "DATE OF BITSTREAM GENERATION:" " $(./show_date.sh $(./read.sh $ADDR))"
printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"


read_next
printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
printf " ║ %-30s  ║ %s                        ║\n" "SHA OF THE SHELL:" " $( cat content | sed 's/^0*//')"
printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"


read_next
printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
printf " ║ %-30s  ║ %s                       ║\n" "SHA OF THE ACCELERATOR:" " $(cat content | sed 's/^0*//')"
printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"


read_next
printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
printf " ║ %-30s  ║ %s                           ║\n" "EMULATED ACCELERATOR: " " $(cat content | xxd -r -p)"
printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"

rm content
