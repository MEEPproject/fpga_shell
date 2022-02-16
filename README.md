Go to the MEEP wiki @ https://wiki.meep-project.eu/index.php/MEEP_Shell#FPGA_SHELL_TCL_building_program for instructions about how 
to use this SW.

The MEEP Shell needs to be used with Vivado 2021.2. The board files for U280/U55C doesn't need to be installed.

It only works on Linux. There is no plan to add Windows support in the middle term. 

The list of supported EAs so far (16/02/2022) is as follows:

dvino\
sargantana\
acme\
openpiton

They can be generated using the correct initialization flag:

make initialize LOAD_EA=dvino\
make initialize LOAD_EA=sargantana\
make initialize LOAD_EA=acme\
make initialize LOAD_EA=openpiton
