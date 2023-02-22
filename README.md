# FPGA Shell
Go to the MEEP wiki @ https://wiki.meep-project.eu/index.php/MEEP_Shell#FPGA_SHELL_TCL_building_program for **_instructions about how to use this SW._**

The MEEP Shell needs to be used with Vivado 2021.2. The board files for U280/U55C doesn't need to be installed. :tools: 

**It only works on Linux**. There is no plan to add Windows support in the middle term. 

## 1.  Supported Emulated Accelerators

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
 
## 2.  Supported Boards

- Alveo U55C
- Alveo U280

To change the default target. Do :

    make u55c
    make u280

## 3. Vivado project

In order to creaet a Vivado project, and generate the **FPGA Shell** around the EA. 


if you are working with **acme**, there are different "flavours" that can be generated. 

To check which flavours we have, you need to do:

    make help_ea

if you want to know the nomenclature:

    make syntax_ea

When you know the name you can use it like this. The names description you have in section 6 :

For example:

    make project EA_PARAM=acme_ea_4a

if you want to add flags:

    make project EA_PARAM+="acme_ea_4a meep pronoc hbm"

It will generate a OpePiton project with Lagarto as a core. There are other conbinations available. 



## 4.  Push with GitLab variables:

    git push -o ci.variable="FPGA_BOARD=u55c" -o ci.variable="CUSTOM_MSG=2x2_withVPU"

    make project EA_PARAMS=pronoc


## 5.  Developers guide:

The MEEP FPGA Shell is built around the **sh**, **shell** and **tcl** folders.

The **sh** folder handle some automatic tasks during the whole flow, working closely with Makefiles.

The **tcl** folder joints most of the Vivado calls, procedures and automated scripts.

The **shell** folder is where all the different IPs that can be part of the Shell (depending on the selected configuration) are stored.

IPs are treated individually, in such a way there is no friction between different set ups, meaning that any combination of IPs can be set with no dependency or incompatibility between them. Which such approach, the Shell can be built  incrementaly, adding more pieces as they are needed. The only exception to this are the shell_mmcm.tcl file, which configures the clock infrastructure for the 
whole design, and the shell_qdma.tcl. The call to these tcls is mandatory, as it will be explained later. 


## 6. Bitstreams Naming convention

In order to have a standar method to the bitstream name releases, and the procedure to generate those. There are mandatory rules to use:

### 6.1. ACME_EA

All the bistreams will use the **ACME_EA** with three letters to better identify the main characteristics:

* First letter: to designate the core (A: *Ariane*; H: *Lagarto Hun*)
* Second letter: to identify the accelerator (x: *no accelerator*; V: *VPU*; G: *VPU+SA-HEVC+SA-NN*)
* Thrid letter: to identify the Memory Tile (x: *no MT*, M: *Memory Tile*)

To complete this information, we will add an extra value to each fields:

* **acme_ea_ahbvcm**; where:  
  - "a" means the number of cores in the system
  - "b" means the number of vector lanes
  - "c" means the number of MT
### 6.2. Environments to work

We have define two differents environments to generate different bitstream depending of the "environment". There are **Production** and **Test** environment.
## Production 	:rocket:

The production environment will be a monthly release. We will work with:

All use **ProNoC** routers

| Bitstream names     | Description           | Status           | 
| :-----------------  |:----------------------| :----------------|
|acme_ea_4a      | *golden reference*     | available        |
| acme_ea_1h16g1m | | **not** available yet. Pending from MT & SAs  |
| acme_ea_4h2v4m  |        |**not** available yet . Pending from MT|
| acme_ea_4h2v2m  |(L1.Ariane) |**not** available yet [pending from MT]|
|Meanwhile 2, 3 & 4 are in place we will include a transition one |
| acme_ea_1h16v   |(L1.Ariane)                | available       |
| acme_ea_4h2v    |(L1.Ariane)                | available       |

:card_box: The FPGA card used here is the **u55c**

There are two ways to execute the pipeline using this environment. By Merge request event :arrow_heading_up: and schedule  (monthly, the 1th):clock1:.

The bitstreams generated will be released in  https://release.meep-project.eu/nexus/#browse/search/raw

### 6.3. Test :fingers_crossed:

The same ones than before with **OP routers**. This will help to ensure nothing is broken on the way .

Including a bitstream with Lagarto Tile: ACME_EA 1Hxx v2.y.z (L1.Tile) with OP routers and ProNoC routers. (Pending)

:card_box: Here we uses the **u280** and **u55c** fpga cards.

If we want to use this environment, we need to use in our *commit message* **#TestCICD**