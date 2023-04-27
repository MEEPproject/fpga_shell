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



echo -e "${G}**********************************************${NC}"
echo -e "${G}*           Running RISCV Tests              *${NC}"
echo -e "${G}**********************************************${NC}"

start_time=$(date +%s.%N)   # get start time in seconds.nanoseconds


# Read the list of items into an array (test_list)
readarray -t test_riscv < $1

for i in "${test_riscv[@]}"
do
   source $BOOT_FILE/boot_acme.sh $i
   #echo "$i"
   sleep 20
done

end_time=$(date +%s.%N)     # get end time in seconds.nanoseconds
elapsed_time=$(echo "$end_time - $start_time" | bc)   # calculate elapsed time

echo "Elapsed time: $elapsed_time seconds"

echo "Loop complete!" # the boot benchmarks has finished

cd "$(pwd)"

echo "$(pwd)"
}

function clean_log() {

inputfile=$1
echo "$inputfile"
outputfile=$2
echo "$outputfile"

sed -i '/picocom v3.1/,/Terminal ready/d; /----------------------------------------/,/Custom Bootloader for MEEP/d; /Terminating... /,/Thanks for using picocom/d' $inputfile
}

function set_file() {
info="./tmp/bin_$2/"
echo "$info"

#set the right path to execute the baremetal test
  sed -i -e "s#^#${info}#"  $1

}

function test_loop_log() {
TEST_LIST=$1
OUTPUT_FILE=$2

readarray -t test_riscv < $TEST_LIST

#we open pico to print output results
#n this script, the & character at the end of the picocom command runs it in the background, so the script can continue executing while picocom is running.

stty -F /dev/ttyUSB2 115200 raw -echo
cat < /dev/ttyUSB2 > $OUTPUT_FILE &
#nohup sh -c "cat /dev/ttyUSB2 > $OUTPUT_FILE" &

start_time=$(date +%s.%N)   # get start time in seconds.nanoseconds

for k in "${test_riscv[@]}"
do
   #echo "$i"
   source $BOOT_FILE/boot_acme.sh $k
   echo "$k"
   tail $OUTPUT_FILE
   sleep 33
done

end_time=$(date +%s.%N)     # get end time in seconds.nanoseconds
elapsed_time=$(echo "$end_time - $start_time" | bc)   # calculate elapsed time

echo "Elapsed time: $elapsed_time seconds"

echo "Kill cat process ..."

{
	sudo pkill cat 2> $OUTPUT_FILE.error
} || {
	echo "pkill cat command failed:"
	cat $OUTPUT_FILE.error || ls
}

#Add a carriage return
echo -e "\r\n" >> $OUTPUT_FILE

echo "FPGA Test completed."
echo "pico status:"
ps -ef | grep ttyUSB2

}

function pico_close() {

   # Send Ctrl-A
   echo -ne '\x01'

   # Send Ctrl-X
   echo -ne '\x18'

   # Wait for picocom to exit
  # wait
}
#menu
if [ $1 == setup ]; then
   setup
elif [ $1 == test_loop ]; then
   run_loop_test $2
elif [ $1 == set_file ]; then
   set_file $2 $3
elif [ $1 == test_loop_log ]; then
   test_loop_log $2 $3
elif [ $1 == pico_close ]; then
   pico_close
elif [ $1 == clean_log ]; then
   clean_log $2 $3
fi
