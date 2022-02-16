#!/bin/bash

## This tcl read line by line a file list with the name of the desired
## files. Then it calls the find command to set the complete path
## and write it back to a file
 
while read line; do
#echo $line >> olakase.flist;
palabra=$line
hola=$(echo $palabra | cut -d' '  -f1)
echo $hola
find . -name "$hola" >> findList.list
done < flist.txt
