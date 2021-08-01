To create a shell around a given accelerator, generate_design.sh needs to be sourced using the URL and the branch of the desired accelerator as arguments. Use:

generate_design.sh <git_repo_url> <commit_sha>.

For instance, for Dvino, it will be:

init_design.sh https://gitlab.bsc.es/meep/rtl_designs/meep_dvino.git 5476d2528d1c37521b80c018f3197f96c5b75fb8

This script is expected to:

1) Clone the targeted accelerator
2) Initialize the given accelerator
3) Create a top level module, the MEEP shell, and the necessary connections between them.
4) Create the Vivado project

Once the process is completed, sh/run_implementation.sh can be sourced to generate the bitstream.


How the accelerator def file should be used:

ACC_TOP_MODULE=shell_dvino_top  #Module name
DDR4,yes,mem_nasti_pack			#DDR4 used, name
HBM,no,0,<name>					#HBM, not used, number of channels, more options
AURORA,no,raw,<name>			#Aurora, not used, raw/dma mode
UART,yes,simple,rxd,txd			#UART, used, simple/full (full=implement the entire core), pinout
ETHERNET,no,<name_rx>,<name_tx>	#Ethernet, name of the interfaces
CLK0,freq,<name>	   			#Clock0 provided by the shell, name of the connection
CLK1,freq						#Clock1 provided by the shell, name of the connection


#There should be a table to map GPIO capabilities. The system could process it an d connect AXI GPIO (PCIe mapped) to custom signals (like the RISCV reset signal).
