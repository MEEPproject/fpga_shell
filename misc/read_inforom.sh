#!/bin/bash

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


function usage() {
    echo ""
    echo " Valid commands:"
    echo ""
    echo "    get date			Retrieves the date of the bitstream generation"
    echo "    get sha shell		Retrieves the sha of the shell"
    echo "    get sha EA			Retrieves the sha of the emulated accelerator"
    echo "    get EA			Retrieves the name of the emulated accelerator"
    echo "    get shell components	Retrieves the list of active components in the shell"
    echo "    read all			Retrieves all the information stored in the infoROM"
    echo ""
}


function get_date(){	
	printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
	printf " ║ %-30s  ║ %5s %5s \n" "DATE OF BITSTREAM GENERATION:" " $(./show_date.sh $(./read.sh 0x400000000))" "║"
	printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"
}

function get_sha_shell(){
	./read.sh 0x400000004
	printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
	printf " ║ %-30s  ║ %5s %26s \n" "SHA OF THE SHELL:" " $( cat content | sed 's/^0*//')" "║"
	printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"
}

function get_sha_EA(){
	./read.sh 0x400000008
	printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
	printf " ║ %-30s  ║ %5s %25s \n" "SHA OF THE ACCELERATOR:" " $(cat content | sed 's/^0*//')" "║"
	printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"
}

function get_EA(){
	./read.sh 0x40000000C
	printf " ╔═════════════════════════════════╦═════════════════════════════════╗\n"
	printf " ║ %-30s  ║ %5s %29s \n" "EMULATED ACCELERATOR:" " $(cat content | xxd -r -p)" "║"
	printf " ╚═════════════════════════════════╩═════════════════════════════════╝\n"
}

function get_shell_components(){
	ADDR=0x40000000C
	printf " ╔═══════════════════════════════════════════════════════════════════╗\n"
	printf " ║ INCLUDES SHELL COMPONENTS: %42s \n" " ║"
	read_next
	for elem in "${shell_components[@]}"
	do
	    # Bash treats null bytes as string terminators, so I substitute them with '_' to avoid warning messages (this happens when it reads an empty position within the ROM)
	    if [[ "$elem" == "$(cat content | xxd -r -p | tr '\0' '_')" ]]
	    then
		word_new=${map_components[$(cat content | xxd -r -p )]}
		offset=$(( 41 + $(( ${#word_new} - 4 )) ))
		offset2=$(( 29 - $(( ${#word_new} - 4 )) ))
		printf " ║ %${offset}s %${offset2}s\n" "║  $word_new" "║"
        	read_next
	    fi
	done
	printf " ║                                                                   ║\n"
	printf " ╚═══════════════════════════════════════════════════════════════════╝\n"
}

function read_all(){
	cat title.txt
	get_date
	get_sha_shell
	get_sha_EA
	get_EA
	get_shell_components
}

usage
while true
do 
   read command
   case "$command" in 
	   "get date")
	   	get_date
     		;;		
	   "get sha shell")
		get_sha_shell
		;;
	   "get sha EA")
		get_sha_EA
		;;
	   "get EA")
	        get_EA
		;;
	   "get shell components")
		get_shell_components
		;;	
	   "read all")
		read_all
		;;
	   "exit")
	       break
	       ;;
	   *)
	       echo "Invalid command"
	       ;;
   esac
done
   
rm content




