#!/bin/bash

# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Solderpad Hardware License v 2.1 (the "License");
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
# 
#     http://www.solderpad.org/licenses/SHL-2.1
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Daniel J.Mazure, BSC-CNS
# Date: 22.02.2022
# Description: 


INSTALL_PATH=/home/tools
#INSTALL_PATH=/opt/MEEP/drivers/
LOAD_BITSTREAM=$INSTALL_PATH/scripts
DMA_IP_DRIVERS=$INSTALL_PATH/drivers/`/bin/hostname`/dma_ip_drivers

export PATH=$DMA_IP_DRIVERS/QDMA/linux-kernel/bin/:$PATH

if [ -x /opt/Xilinx/Vivado/2020.1/settings64.sh ]; then 
   source /opt/Xilinx/Vivado/2020.1/settings64.sh
elif [ -x /opt/Xilinx/Vivado/2021.2/settings64.sh ]; then
   source /opt/Xilinx/Vivado/2021.2/settings64.sh
fi

# check that vivado is on the PATH

vivado_path=`which vivado`

if [  "x$vivado_path" == "x" ]; then
	echo "ERROR: No Xilinx Vivado installation found!!"
	echo "       Please load the vivado settings"
	exit 1
fi

# check that QDMA utilities are on the PATH
dmactl_path=`which dma-ctl`

if [ "x$dmactl_path" == "x" ]; then
	echo Please add the QDMA tools on the PATH
	exit 1
fi

NQUEUES=2

if [ x$1 == x--dryrun ]; then
	dryrun=/bin/true
	shift
else
	dryrun=/bin/false
fi

if [ x$1 == x ]; then
	echo Missing arguments
	echo Usage: $0 [--dryrun] module-type bitstream-file.bit
	echo "    module-types supported: xocl xdma qdma"
	exit 1
fi

if [ $1 == xocl ]; then
	load=xocl
elif [ $1 == xdma ]; then
	load=xdma
elif [ $1 == qdma ]; then
	load=qdma
else
	echo "Module type $1 not supported, or missing module type parameter"
	exit 1
fi
shift

if [ x$1 == x ]; then
	echo "Missing bitstream argument"
	exit 1
fi
bitfile=$1

if [ ! -r $bitfile ]; then
	echo "Error  $bitfile  bitstream does not exist or it is not readable"
	exit 1
fi



fpgajtag=`lsusb -vd 0403: 2>&1 | grep iSerial | awk ' { print $3; } '`

if [ x$fpgajtag == x ]; then
	echo FPGA jtag not detected
	exit 1
fi

echo FPGA jtag detected: $fpgajtag

current_modules=()

for mod in xocl xclmgmt qdma_pf qdma_vf xdma; do
   lsmod | grep "^$mod"
   if [ $? == 0 ]; then
      current_modules=(${current_modules[@]} $mod)
   fi
done

echo Modules currently loaded: ${current_modules[@]}

for mod in ${current_modules[@]} ; do
	   echo Removing module $mod: sudo rmmod $mod
	   $dryrun || sudo rmmod $mod
	   if [ $? != 0 ]; then
		echo ERROR: Removing module $mod failed...
		echo ... for security reasons, stopping the script
		exit 1
	   fi
done


# remove pcie devices

for dev in $(lspci -m -d 10ee:| cut -d' ' -f 1)
do
	devDir="/sys/bus/pci/devices/0000:$dev"
	if [ -d $devDir ]
	then
		echo Removing $devDir: sudo dd of=/sys/bus/pci/devices/0000:$dev/remove 
		#$dryrun || echo 1 | $LOAD_BITSTREAM/root-action dd $dev remove

		$dryrun || echo 1 | sudo dd of=/sys/bus/pci/devices/0000:$dev/remove
		if [ $? -ne 0 ]; then
			echo "Error removing device $devDir"
			exit 1
		fi
#		if [ $dryrun == 0 ]; then
#			echo 1 | $LOAD_BITSTREAM/root-action dd $devDir remove
#			if [ $? -ne 0 ]
#			then
#				exit 1
#			fi
#		fi
	fi
done

sleep 2



#if [ $dryrun == 0 ]; then
echo "Loading bitstream file through jtag..."
$dryrun || vivado -nolog -nojournal -mode batch \
	    -source $LOAD_BITSTREAM/load-bitstream.tcl -tclargs $bitfile $fpgajtag
	if [ $? -ne 0 ] ; then
		echo "Error loading the bitstream   $bitfile"
		exit 1
	fi
echo "Bitstream   $bitfile   loaded."
killall hw_server
#fi


sleep 2

#echo Rescanning pcie devices
#$dryrun || echo 1 | sudo dd of=/sys/bus/pci/rescan
##if [ $dryrun == 0 ]; then
##	echo 1 | $LOAD_BITSTREAM/root-action rescan
##fi

sleep 2

case $load in
   xocl) echo "Loading bitstreams for modules xocl/xclmgmt automatically loads"
	 echo "both modules. Please check that they appear in the next listing:"
	 echo "==== listing start ===="
         lsmod | grep -i -e xocl -e xclmgmt
	 echo "===== listing end ====="
        ;;
   xdma) echo "Loading bitstreams for module xdma"
         if [ ! -r $DMA_IP_DRIVERS/XDMA/linux-kernel/xdma/xdma.ko ]; then
	    echo "Error xdma.ko does not exist or it is not readable"
	    exit 1
         fi
	 echo "Loading module xdma.ko"
         sudo insmod $DMA_IP_DRIVERS/XDMA/linux-kernel/xdma/xdma.ko
        ;;
   qdma) echo -n Waiting... :
         sleep 4
         lsmod | grep qdma_pf
         if [ $? == 0 ]; then
           echo "Unloading default qdma-pf.ko"
           sudo rmmod qdma_pf
           sleep 3
         fi
         lsmod | grep qdma_vf
         if [ $? == 0 ]; then
           echo "Unloading default qdma-vf.ko"
           sudo rmmod qdma_vf
           sleep 3
         fi
         lsmod | grep xdma
         if [ $? == 0 ]; then
           echo "Unloading default xdma.ko"
           sudo rmmod xdma
           sleep 3
         fi
for dev in $(lspci -m -d 10ee:| cut -d' ' -f 1)
do
	devDir="/sys/bus/pci/devices/0000:$dev"
	if [ -d $devDir ]
	then
		echo Removing $devDir: sudo dd of=/sys/bus/pci/devices/0000:$dev/remove 
		#$dryrun || echo 1 | $LOAD_BITSTREAM/root-action dd $dev remove

		$dryrun || echo 1 | sudo dd of=/sys/bus/pci/devices/0000:$dev/remove
		if [ $? -ne 0 ]; then
			echo "Error removing device $devDir"
			exit 1
		fi
#		if [ $dryrun == 0 ]; then
#			echo 1 | $LOAD_BITSTREAM/root-action dd $devDir remove
#			if [ $? -ne 0 ]
#			then
#				exit 1
#			fi
#		fi
	fi
done

sleep 2
         if [ ! -r $DMA_IP_DRIVERS/QDMA/linux-kernel/bin/qdma-pf.ko ]; then
	    echo "Error qdma-pf.ko does not exist or it is not readable"
	    exit 1
         fi
	 echo "Loading module qdma-pf.ko"
	 $dryrun || sudo insmod $DMA_IP_DRIVERS/QDMA/linux-kernel/bin/qdma-pf.ko
         sleep 4
echo Rescanning pcie devices
$dryrun || echo 1 | sudo dd of=/sys/bus/pci/rescan
sleep 2
##if [ $dryrun == 0 ]; then
##	echo 1 | $LOAD_BITSTREAM/root-action rescan
##fi
        ;;
esac

if [ $load == qdma ]; then

 for dev in $(lspci -m -d 10ee:| cut -d' ' -f 1)
 do
   echo Dealing with pcie at $dev
   devname=qdma`sed -e 's/://' -e 's/\.//' <<+++
$dev
+++
`
   echo Creating queues on $devname
   echo sudo dd of=/sys/bus/pci/devices/0000:$dev/qdma/qmax
   $dryrun || echo $NQUEUES | sudo dd of=/sys/bus/pci/devices/0000:$dev/qdma/qmax
   if [ $? != 0 ]; then
      echo ERROR: Adding queue max in devices/0000:$dev/qdma failed...
      echo ... for security reasons, stopping the script
      exit 1
   fi

   sleep 2

   echo dma-ctl $devname q add mode mm idx 1 dir bi
   $dryrun || dma-ctl $devname q add mode mm idx 1 dir bi

   sleep 2

   echo dma-ctl $devname q start idx 1 dir bi
   $dryrun || dma-ctl $devname q start idx 1 dir bi

   sleep 2

   echo sudo chmod go+rw /dev/$devname-MM-1
   $dryrun || sudo chmod go+rw /dev/$devname-MM-1

   sleep 2

   echo sudo chmod go+rw /sys/bus/pci/devices/0000:$dev/resource0
   $dryrun || sudo chmod go+rw /sys/bus/pci/devices/0000:$dev/resource0
   echo sudo chmod go+rw /sys/bus/pci/devices/0000:$dev/resource0_wc
   $dryrun || sudo chmod go+rw /sys/bus/pci/devices/0000:$dev/resource0_wc
   echo sudo chmod go+rw /sys/bus/pci/devices/0000:$dev/resource2
   $dryrun || sudo chmod go+rw /sys/bus/pci/devices/0000:$dev/resource2
   echo sudo chmod go+rw /sys/bus/pci/devices/0000:$dev/resource2_wc
   $dryrun || sudo chmod go+rw /sys/bus/pci/devices/0000:$dev/resource2_wc

 done

fi

echo New PCIe devices loaded:
lspci -vd 10ee:

