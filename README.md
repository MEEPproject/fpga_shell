To create a shell around the accelerator, fill the ea_url.txt file:

For instance, for Dvino, it will be:

EMULATED_ACCELERATOR_REPO: https://gitlab.bsc.es/meep/rtl_designs/meep_dvino.git 
EMULATED_ACCELERATOR_SHA: 5476d2528d1c37521b80c018f3197f96c5b75fb8

Both the Repository and the specific commit need to be provided.

After this, the flow is Makefile-based. In order to generate the design at your end, you need to:

1) "make initialize", to clone the targeted accelerator
2) "make vivado", to create the vivado design. It will be created under ./project as "system.xpr"
3) "make synthesis/implementation/bitstream", depending on how far in the design flow you desire to go.
4) "make validation" will parse the reports generated in the implementation stage.


From the EA perspective, the accelerator def file should be used like shown below:

ACC_TOP_MODULE=shell_dvino_top  #Module name
DDR4,yes,mem_nasti_pack			#DDR4 used, name
HBM,no,0,<name>					#HBM, not used, number of channels, more options
AURORA,no,raw,<name>			#Aurora, not used, raw/dma mode
UART,yes,simple,rxd,txd			#UART, used, simple/full (full=implement the entire core), pinout
ETHERNET,no,<name_rx>,<name_tx>	#Ethernet, name of the interfaces
CLK0,freq,<name>	   			#Clock0 provided by the shell, name of the connection
CLK1,freq						#Clock1 provided by the shell, name of the connection


#There should be a table to map GPIO capabilities. The system could process it an d connect AXI GPIO (PCIe mapped) to custom signals (like the RISCV reset signal).
