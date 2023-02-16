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

Push with GitLab variables:

git push -o ci.variable="FPGA_BOARD=u55c" -o ci.variable="CUSTOM_MSG=2x2_withVPU"

make project EA_PARAMS=pronoc


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

# Bitstreams Naming convention

In order to have a standar method to the bitstream name releases, and the procedure to generate those. There are mandatory rules to use:

# ACME_EA

All the bistreams will use the **ACME_EA** with three letters to better identify the main characteristics:

* First letter: to designate the core (A: *Ariane*; H: *Lagarto Hun*)
* Second letter: to identify the accelerator (x: *no accelerator*; V: *VPU*; G: *VPU+SA-HEVC+SA-NN*)
* Thrid letter: to identify the Memory Tile (x: *no MT*, M: *Memory Tile*)

To complete this information, we will add an extra value to each fields:

* **acme_ea_aHbVcM**; where:  
  - "a" means the number of cores in the system
  - "b" means the number of vector lanes
  - "c" means the number of MT
## Environments to work

We have define two differents environments to generate different bitstream depending of the "environmnet". There are production and Test environmnet.
## Production

The production environment will be a monthly release. We will work with:

| Production bitstreams      | Description           | Status           | 
| -------------  |:---------------------:| :---------------------:|
|    all ProNoC                                                      |
| acme_ea_4A  |  golden reference | available  |
|acme_ea_1H16G1M |pending from MT & SAs|not available yet|
|ACME_EA 4H2V4M |pending from MT|not available yet|
|ACME_EA 4H2V2M|(L1.Ar) [pending from MT]|not available yet|
|    Meanwhile 2, 3 & 4 are in place we will include a transition one                                              |
|ACME_EA 1H16Vx|(L1.Ar)|available|
|ACME_EA 4H2Vx|(L1.Ar)|available|





## Test 