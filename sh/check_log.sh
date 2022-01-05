#!/bin/bash

INPUT_FILE=$1
#GOOD_STRING="Welcome to Buildroot"
GOOD_STRING=$2

if [ ! -f "$INPUT_FILE" ]; then
       printf "Log file doesn't exist!\n"	
       exit 1
fi

ret=0


#If the good string is found, the variable is NOT empty and the next if is not taken
LoginPrompt="`grep $INPUT_FILE -e "$GOOD_STRING" || true`"
echo $LoginPrompt

if [ -z "$LoginPrompt" ]; then	
    echo "The log output is not as expected"
    ret=1
fi

if [ "$ret" -eq 1 ]; then
    echo "Log validation failed"
    exit 1
else
    echo "Log validation passed"
    #exit 0
fi	

