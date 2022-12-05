#!\bin\bash
THIS_DIR=$1

# This converts the date (from epoc) to hexadecimal value
printf '%x\r\n' $(date +%s) > $THIS_DIR/misc/initrom.mem
# This extracts the short SHA, which is 7 digits. We need to pad it
SHA_SHELL=`git rev-parse --short HEAD`
PAD_SHA="0"$SHA_SHELL

echo "PAD_SHA" >> $THIS_DIR/misc/initrom.mem

cd $THIS_DIR/accelerator

# Do the same for the ACC SHA
SHA_ACC=`git rev-parse --short HEAD`
PAD_SHA="0"$SHA_ACC

echo "PAD_SHA" >> $THIS_DIR/misc/initrom.mem

cd $THIS_DIR

# The PCIe script should do the following:
# Convert to decimal the stored hexadecimal 
#printf '%d\n' `echo $output`
# ... so it can be read by date
#date --date @${output}
