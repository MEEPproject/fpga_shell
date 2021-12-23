#!/bin/bash
 
MODULE=$1
MODULE=${MODULE,,}
ROOT_DIR=$(pwd)
EA_FILE=$ROOT_DIR/ea_url.txt
SUPP_DIR=$ROOT_DIR/support

EA_NAME=$(grep -r -m 1 $EA_FILE -e 'EMULATED_ACCELERATOR_NAME' | awk -F ':' '$2 {print $2}')
SUPP_LIST=$(find $SUPP_DIR/* -maxdepth 1 -type d -printf "%f\n")

 
if [ "$MODULE" == "" ]; then
       echo "[MEEP] INFO: Loading$EA_NAME module"	       	   
else
	if [ ! -d "$SUPP_DIR/$MODULE" ]; then
       echo -e "[MEEP] INFO: Module $MODULE directory doesn't exist!"	
	   echo -e "Supported modules:\r\n\r\n$SUPP_LIST"
       #exit 1
	else
		echo -e "\r\nLoading module $MODULE"
		cp $SUPP_DIR/$MODULE/ea_url.txt $EA_FILE
    fi	   
fi

