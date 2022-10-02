Go to the MEEP wiki @ https://wiki.meep-project.eu/index.php/MEEP_Shell#FPGA_SHELL_TCL_building_program for instructions about how 
to use this SW.

The MEEP Shell needs to be used with Vivado 2021.2. The board files for U280/U55C doesn't need to be installed.

It only works on Linux. There is no plan to add Windows support in the middle term. 

The list of supported EAs so far (17/02/2022) is as follows:

dvino\
sargantana\
acme\
openpiton

They can be generated using the correct initialization flag:

make initialize LOAD_EA=dvino\
make initialize LOAD_EA=sargantana\
make initialize LOAD_EA=acme\
make initialize LOAD_EA=openpiton


Developers guide:

The MEEP FPGA Shell is built around the sh, shell and tcl folders. The sh folder 
handle some automatic tasks during the whole flow, working closely with Makefiles. The tcl folder joints most of the Vivado calls, procedures and automated scripts. The shell folder is where all the different IPs that can be part of the Shell (depending on the selected configuration) are stored. 
IPs are treated individually, in such a way there is no friction between different
set ups, meaning that any combination of IPs can be set with no dependency
or incompatibility between them. Which such approach, the Shell can be built 
incrementaly, adding more pieces as they are needed. The only exception to this 
are the shell_mmcm.tcl file, which configures the clock infrastructure for the 
whole design, and the shell_qdma.tcl. The call to these tcls is mandatory, as it 
will be explained later. 

