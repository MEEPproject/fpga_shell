#!/bin/bash

FILENAME=olakase.bin
#FILESIZE=$(stat -c%s $FILENAME)
DATA=$1

#echo -n "$DATA" > $FILENAME
echo -n $DATA | xxd -r -p > $FILENAME

FILESIZE=$(du -b $FILENAME | cut -f1)
ADDR=$2

echo -e "Writing $1 which is $FILESIZE bytes to ADDRESS $ADDR\r\n"

dma-ctl qdma09000 reg write bar 2 0x0 0x3

sleep 0.1

dma-to-device -d /dev/qdma09000-MM-1 -s $FILESIZE -a $ADDR -f $FILENAME #load the bbl into main memory.

rm $FILENAME

