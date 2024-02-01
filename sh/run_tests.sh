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


abs_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"



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
   info="$abs_path/tmp/bin/bin_$2/"

   if [ -e "$info" ]; then
      #set the right path to execute the baremetal test
      sed -i -e "s#^#${info}#"  $1
   else
      echo "Path does not exist: $info"
      exit 1
   fi

}


#menu
if [ $1 == setup ]; then
   setup
elif [ $1 == set_file ]; then
   set_file $2 $3
elif [ $1 == clean_log ]; then
   clean_log $2 $3
fi
