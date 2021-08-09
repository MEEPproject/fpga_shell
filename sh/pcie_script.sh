#!/bin/bash

FILENAME=$1
#FILESIZE=$(stat -c%s $FILENAME)
FILESIZE=$(du -b $FILENAME | cut -f1)

echo -e "Booting using $FILENAME image file which is $FILESIZE bytes\r\n"

dma-ctl qdma08000 reg write bar 2 0x0 0x0 
sleep 1 
dma-to-device -d /dev/qdma08000-MM-1 -s $FILESIZE -a 0x80000000 -f $FILENAME #load the bbl into main memory.
dma-ctl qdma08000 reg write bar 2 0x0 0x1 #Release Lagarto's reset
