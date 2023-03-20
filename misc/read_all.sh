ii#!/bin/bash

ADDR=0x400000000
shell_components=("PCIE" "DDR4" "HBMM" "AURO" "UART" "ETHE" "BROM" "BRAM")
fullname_comp=("PCIE" "DDR4" "HBM" "AURORA" "UART" "ETHERNET" "BROM" "BRAM")

declare -A map_components

function read_next {
  ADDR=$(($ADDR + 4))  
  ./read.sh "$ADDR"
}

for i in "${!shell_components[@]}"
do
   map_components["${shell_components[$i]}"]="${fullname_comp[$i]}"
done	


cat title.txt

printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
printf " ║ %-30s  ║ %5s %5s \n" "DATE OF BITSTREAM GENERATION:" " $(./show_date.sh $(./read.sh $ADDR))" "║"
printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"


read_next
printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
printf " ║ %-30s  ║ %5s %26s \n" "SHA OF THE SHELL:" " $( cat content | sed 's/^0*//')" "║"
printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"


read_next
printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
printf " ║ %-30s  ║ %5s %25s \n" "SHA OF THE ACCELERATOR:" " $(cat content | sed 's/^0*//')" "║"
printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"


read_next
printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
printf " ║ %-30s  ║ %5s %29s \n" "EMULATED ACCELERATOR:" " $(cat content | xxd -r -p)" "║"
printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"


printf " ╔═══════════════════════════════════════════════════════════════════╗\n"
printf " ║ INCLUDES SHELL COMPONENTS: %42s \n" " ║"
read_next
for elem in "${shell_components[@]}"
do
    # Bash treats null bytes as string terminators, so I substitute them with '_' to avoid warning messages (this happens when it reads an empty position within the ROM)
    if [[ "$elem" == "$(cat content | xxd -r -p | tr '\0' '_')" ]]
    then
	word_new=${map_components[$(cat content | xxd -r -p )]}
	offset=$(( 39 + $(( ${#word_new} - 4 )) ))
	offset2=$(( 29 - $(( ${#word_new} - 4 )) ))
	printf " ║ %${offset}s %${offset2}s\n" "$word_new" "║"
        read_next
    fi
done
printf " ║                                                                   ║\n"
printf " ╚═══════════════════════════════════════════════════════════════════╝\n"

rm content
