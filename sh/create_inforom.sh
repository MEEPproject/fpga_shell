#!/bin/bash

#This executes without errors from the context of the Makefile, which is the one calling this script.
#It won't work when called from the scripts' context.

THIS_DIR=$(pwd) # ~/git_repo/fpga_shell
PARENT_DIR="$(dirname "$THIS_DIR")" #Returns to parent directory fpga_shell (git_repo)

SHELL_DEF_FILE=$THIS_DIR/accelerator/piton/design/chipset/meep_shell/shell2acc_def.csv
FILE_GENERATED=$THIS_DIR/misc/initrom.mem #primera prueba con txt

# This converts the date (from epoc) to hexadecimal value
printf '%x\r\n' $(date +%s) > $FILE_GENERATED
# This extracts the short SHA, which is 7 digits. We need to pad it
SHA_SHELL=`git rev-parse --short HEAD`
PAD_SHA="0"$SHA_SHELL

echo "$PAD_SHA" >> $FILE_GENERATED

cd $THIS_DIR/accelerator

# Do the same for the ACC SHA
SHA_ACC=`git rev-parse --short HEAD`
PAD_SHA="0"$SHA_ACC

echo "$PAD_SHA" >> $FILE_GENERATED
cd $PARENT_DIR

# The PCIe script should do the following:
# Convert to decimal the stored hexadecimal 
#printf '%d\n' `echo $output`
# ... so it can be read by date
#date --date @${output}


#stores [4 bytes]/[word] every row
#In ASCII, every letter occupies a [byte], so either I reduce the names, or padd them with an extra char

sed -n 1p $SHELL_DEF_FILE | cut -d= -f2 | xxd -p -c 4 >> $FILE_GENERATED

for i in {2..10}
do
    if [ "$(sed -n "$i"p "$SHELL_DEF_FILE" | cut -d, -f2)" == "yes" ]; then
        case $i in
            2)
            echo "PCIE" | xxd -p -c 4 >> $FILE_GENERATED
            ;;
            3)
            echo "DDR4" |  xxd -p -c 4 >> $FILE_GENERATED
            ;;
            4)
            echo "HBMM" |  xxd -p -c 4 >> $FILE_GENERATED #HBMeMory
            ;;
            6)
            echo "AURO" |  xxd -p -c 4 >> $FILE_GENERATED 
            ;;
            7)
            echo "UART" |  xxd -p -c 4 >> $FILE_GENERATED
            ;;
            8)
            echo "ETHE" |  xxd -p -c 4 >> $FILE_GENERATED
            ;;
            9) #La línia 9 de shell2acc_def.csv debería borrarse (BROM)
            echo "BROM" |  xxd -p -c 4 >> $FILE_GENERATED
            ;;
            10)
            echo "BRAM" |  xxd -p -c 4 >> $FILE_GENERATED
            ;;
        esac
    fi
done

sed -i '/0a/d' $FILE_GENERATED 

