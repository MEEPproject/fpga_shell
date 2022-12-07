#!/bin/bash


ADDR=$1

#echo -e "READ 4 bytes from ADDRESS $ADDR\r\n"

dma-ctl qdma09000 reg write bar 2 0x0 0x3 >> null

sleep 0.1

dma-from-device -d /dev/qdma09000-MM-1 -s 4 -a $ADDR -f readback >> null

truncate -s %4 readback
objcopy -I binary -O binary --reverse-bytes=4 readback

cat readback | xxd  -c 4 | awk '{print $2 $3}' > olakase

cat olakase

#fpgadate=$(echo $((16#`cat olakase`)))

#echo $fpgadate
# ... so it can be read by date
#date --date @${fpgadate}


rm olakase
rm readback
