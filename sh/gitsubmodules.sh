#!bin/bash
ROOT_DIR=$(pwd)
ACC_DIR=$ROOT_DIR/accelerator
REPO_URL=$1
REPO_SHA=$2
#REPO_URL="https://gitlab.bsc.es/meep/rtl_designs/meep_dvino.git"

#whoami ? gilab-runner -> don't do the update

## Retrieve MEEP IPs --> Aurora, Ethernet ...
git submodule update --init
echo "[MEEP] INFO: Retrieving $IP_NAME as accelerator..."
git clone $REPO_URL accelerator
cd $ACC_DIR
git checkout $REPO_SHA 
cd $ROOT_DIR
echo "[MEEP] INFO: Done"
