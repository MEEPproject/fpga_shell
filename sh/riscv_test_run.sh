#!/bin/bash
#Description: This script handle the automatazion to run the riscv-benchmarks to be use it in the ci gitlab
#Engineer: Francelly Cano

#Colors
R='\033[0;0;31m'    #Red
BR='\033[1;31m'     #Bold Red 
BIR='\033[1;3;31m'  #Bold Italic Red
Y='\033[0;0;93m'    #Yellow
BY='\033[1;0;93m'   #Bold Yellow
BC='\033[1;36m'     #Bold Cyan
G='\033[0;32m'      #Green
BP='\033[1;35m'     #Bold Purple
BW='\033[1;37m'     #Bold White
NC='\033[0;0;0m'        #NO COLOR

function setup() {


## GCC and RISCV GCC setup
export CXX=g++ CC=gcc
# customize this to a fast local disk
if [ x$RISCV == x ]; then
  export RISCV=/home/tools/openpiton/riscv_install
fi

# setup paths
export PATH=$RISCV/bin:$PATH

echo
echo "----------------------------------------------------------------------"
echo "openpiton/lagarto path setup $RISCV"
echo "----------------------------------------------------------------------"
echo
}


BOOT_FILE=/home/tools/fpga-tools/boot_riscv

function run_loop_test() {

test_riscv=(histogram mt-histogram int-median int-multiply qsort rsort int-spmv int-vvadd int-matrix_mult fibonacci towers int-bubblesort fd-median fd-multiply fd-spmv fd-vvadd fd-matrix_mult fd-bubblesort dhrystone mm)



echo -e "${G}**********************************************${NC}"
echo -e "${G}*           Running RISCV Tests              *${NC}"
echo -e "${G}**********************************************${NC}"

start_time=$(date +%s.%N)   # get start time in seconds.nanoseconds

for i in "${test_riscv[@]}"
do
   source $BOOT_FILE/boot_acme.sh $i.bin
   #echo "$i"
   sleep 20
done

end_time=$(date +%s.%N)     # get end time in seconds.nanoseconds
elapsed_time=$(echo "$end_time - $start_time" | bc)   # calculate elapsed time

echo "Elapsed time: $elapsed_time seconds"

echo "Loop complete!" # the boot benchmarks has finished

cd "$(pwd)"
}

function clean_log() {

inputfile=$1
echo "$inputfile"
outputfile=$2
echo "$outputfile"

sed -i '/picocom v3.1/,/Terminal ready/d; /----------------------------------------/,/Custom Bootloader for MEEP/d; /Terminating... /,/Thanks for using picocom/d' $inputfile
}
#menu
if [ $1 == setup ]; then
   setup
elif [ $1 == test_loop ]; then
   run_loop_test
elif [ $1 == clean_log ]; then
   clean_log $2 $3
fi
