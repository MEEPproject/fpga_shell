#!/bin/bash

ADDR=$1 #First address where the infoROM is placed according to Vivado's address editor : 0x4000000000
PCIE_SLOT=`lspci -m -d 10ee:| cut -d " " -f 1 | cut -d ":" -f 1`
#We are filtering the output of lscpi (list of PCIe in the system) with the vendor ID (Xilinx PCIe) 10ee, and the flag -d
#this number will differ depending on the server, so it can't be hardcoded. 
#result of this will be a 2 digit number z.B. 08

QDMA_PCI="qdma${PCIE_SLOT}000" #Constructs the PCI device identifier

#Writes a value to the second BAR (base address register) of the QDMA PCI device identified by QDMA_PCI. Idk why it is this concrete value, but it seems that it is needed to properly configure the QDMA device for the subsequent DMA read operation.
dma-ctl $QDMA_PCI reg write bar 2 0x0 0x3 >> /dev/null 

sleep 0.1

#Reads data from the QDMA device into a file called "readback"
dma-from-device -d /dev/$QDMA_PCI-MM-1 -s 4 -a $ADDR -f readback >> /dev/null

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
