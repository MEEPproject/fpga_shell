[![pipeline status](https://gitlab.bsc.es/meep/FPGA_implementations/AlveoU280/fpga_shell/badges/develop/ssh_connection/pipeline.svg)](https://gitlab.bsc.es/meep/FPGA_implementations/AlveoU280/fpga_shell/-/commits/develop/ssh_connection)

# FPGA Shell
Go to the MEEP wiki @ https://wiki.meep-project.eu/index.php/MEEP_Shell#FPGA_SHELL_TCL_building_program for **_instructions about how to use this SW._**

The MEEP Shell needs to be used with Vivado 2021.2. The board files for U280/U55C doesn't need to be installed. :tools: 

**It only works on Linux**. There is no plan to add Windows support in the middle term. 

## Supported Emulated Accelerators

The list of supported EAs so far (17/02/2022) is as follows:

- acme
- ariane
- dvino
- ea_demo
- epac
- eprocessor
- pronoc
- sargantana

They can be generated using the correct initialization flag:

For example:

    make initialize LOAD_EA=acme
    make initialize LOAD_EA=dvino
    make initialize LOAD_EA=sargantana
    
Every EA has a folder  `fpga_shell/support` with a ea_url.txt file. This file contains the Git URL and the commit SHA. If it is necessary to change the commit SHA to point a specific commit this is the place to modify it.
 
## Supported Boards

- Alveo U55C
- Alveo U280

To change the default target. Do  `make u55c` or `make u280`. 

## Vivado project

In order to creaet a Vivado project, and generate the **FPGA Shell** arount the EA. 
Do `make project`

if you are working with acme, there are different "flavours" that can be generated. For example
    `make project EA_PARAM=acme`

It will generate a OpePiton project with Lagarto as a core. There are other conbinations available. 



## Push with GitLab variables:

    git push -o ci.variable="FPGA_BOARD=u55c" -o ci.variable="CUSTOM_MSG=2x2_withVPU"

    make project EA_PARAMS=pronoc


## Developers guide:

The MEEP FPGA Shell is built around the **sh**, **shell** and **tcl** folders.

The **sh** folder handle some automatic tasks during the whole flow, working closely with Makefiles.

The **tcl** folder joints most of the Vivado calls, procedures and automated scripts.

The **shell** folder is where all the different IPs that can be part of the Shell (depending on the selected configuration) are stored.

IPs are treated individually, in such a way there is no friction between different set ups, meaning that any combination of IPs can be set with no dependency or incompatibility between them. Which such approach, the Shell can be built  incrementaly, adding more pieces as they are needed. The only exception to this are the shell_mmcm.tcl file, which configures the clock infrastructure for the 
whole design, and the shell_qdma.tcl. The call to these tcls is mandatory, as it will be explained later. 

