#!/bin/bash
#Description: This script automate to run the riscv-benchmarks to be use it in the ci gitlab
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


#F1. This function is used to set the env flags
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

#F2. Clean the log, just see the baremetal results
function clean_log() {

inputfile=$1
echo "$inputfile"
outputfile=$2
echo "$outputfile"

sed -i '/picocom v3.1/,/Terminal ready/d; /----------------------------------------/,/Custom Bootloader for MEEP/d; /Terminating... /,/Thanks for using picocom/d' $inputfile
}

#F3.Set the right path to use in the CI for any case
function set_file() {
   info="./tmp/bin_$2/"
   echo "$info"

   #set the right path to execute the baremetal test
   sed -i -e "s#^#${info}#"  $1

}

#F4. Loop the baremetal, we boot all the test in the loop then we are printing the results
function test_loop_log() {
   TEST_LIST=$1
   OUTPUT_FILE=$2
   BOOT_FILE=$3

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
      source $BOOT_FILE $k
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


#menu
if [ $1 == setup ]; then
   setup
elif [ $1 == set_file ]; then
   set_file $2 $3
elif [ $1 == test_loop_log ]; then
   test_loop_log $2 $3 $4
elif [ $1 == clean_log ]; then
   clean_log $2 $3
fi
