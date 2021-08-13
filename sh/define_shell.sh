#This could be done with a recursive loop which walks a list of interfaces

ROOT_DIR=$(pwd)
ACC_DEF=$ROOT_DIR/accelerator/meep_shell/accelerator_def.txt

DDR4="`grep -rn -m 1 $ACC_DEF -e 'DDR4' | awk -F ',' '$2 {print $2}'`"
DDR4_ifname="`grep -rn $ACC_DEF -e 'DDR4' | awk -F ',' '$3 {print $3}'`"

HBM="`grep -rn $ACC_DEF -e 'HBM' | awk -F ',' '$2 {print $2}'`"
HBM_ifname="`grep -rn $ACC_DEF -e 'HBM' | awk -F ',' '$3 {print $3}'`"


AURORA="`grep -rn $ACC_DEF -e 'AURORA' | awk -F ',' '$2 {print $2}'`"
AURORA_ifname="`grep -rn $ACC_DEF -e 'AURORA' | awk -F ',' '$4 {print $4}'`"

UART="`grep -rn $ACC_DEF -e 'UART' | awk -F ',' '$2 {print $2}'`"

ETHERNET="`grep -rn $ACC_DEF -e 'ETHERNET' | awk -F ',' '$2 {print $2}'`"
ETHERNET_ifname="`grep -rn $ACC_DEF -e 'ETHERNET' | awk -F ',' '$3 {print $3}'`"

AURORA_MODE="`grep -rn $ACC_DEF -e 'AURORA' | awk -F ',' '$3 {print $3}'`"
UART_MODE="`grep -rn $ACC_DEF -e 'UART' | awk -F ',' '$3 {print $3}'`"
UART_ifname="`grep -rn $ACC_DEF -e 'UART' | awk -F ',' '$4 {print $4}'`"
UART_irq="`grep -rn $ACC_DEF -e 'UART' | awk -F ',' '$5 {print $5}'`"

BROM="`grep -rn $ACC_DEF -e 'BROM' | awk -F ',' '$2 {print $2}'`"
BROM_initname="`grep -rn $ACC_DEF -e 'UART' | awk -F ',' '$3 {print $3}'`"

CLK0_ifname="`grep -rn $ACC_DEF -e 'CLK0' | awk -F ',' '$3 {print $3}'`"
CLK0_freq="`grep -rn $ACC_DEF -e 'CLK0' | awk -F ',' '$2 {print $2}'`"

RST0_ifname="`grep -rn $ACC_DEF -e 'RESET' | awk -F ',' '$3 {print $3}'`"

ENV_FILE=$ROOT_DIR/tcl/shell_env.tcl

echo "set g_DDR4 $DDR4"                    >  $ENV_FILE
echo "set g_DDR4_ifname $DDR4_ifname"      >> $ENV_FILE
echo "set g_HBM  $HBM"                     >> $ENV_FILE
echo "set g_HBM_ifname $HBM_ifname"        >> $ENV_FILE
echo "set g_AURORA $AURORA"                >> $ENV_FILE
echo "set g_AURORA_ifname $AURORA_ifname"  >> $ENV_FILE
echo "set g_UART $UART"                    >> $ENV_FILE
echo "set g_ETHERNET $ETHERNET"            >> $ENV_FILE
echo "set g_BROM $BROM"                    >> $ENV_FILE
echo ""				    	   >> $ENV_FILE
echo "set g_AURORA_MODE $AURORA_MODE"      >> $ENV_FILE
echo "set g_UART_MODE $UART_MODE"          >> $ENV_FILE
echo "set g_UART_ifname $UART_ifname" 	   >> $ENV_FILE
echo "set g_UART_irq $UART_irq" 	   >> $ENV_FILE
echo "set g_BROM_initname  $BROM_initname" >> $ENV_FILE
echo "set g_CLK0	 $CLK0_ifname"     >> $ENV_FILE
echo "set g_CLK0_freq $CLK0_freq"          >> $ENV_FILE
echo "set g_RST0     $RST0_ifname"         >> $ENV_FILE

echo "Shell enviroment file created on $ENV_FILE"
