<div align="center">
    <img src="Images/meep-logo-symbol.png" width="200px" alt="<MEEP logo>"/> 


<br/>
<h1 align="center">MEEP FPGA Shell 
<br/>
<br/>
</div>
<div align="center">
Go to the MEEP wiki @ https://wiki.meep-project.eu/index.php/MEEP_Shell#FPGA_SHELL_TCL_building_program for **_instructions about how to use this SW._**

The MEEP Shell needs to be used with Vivado 2021.2. The board files for U280/U55C doesn't need to be installed. :tools:

**It only works on Linux**. There is no plan to add Windows support in the middle term.

## 1. Supported Emulated Accelerators

[![pipeline status](https://gitlab.bsc.es/meep/FPGA_implementations/AlveoU280/fpga_shell/badges/develop/ssh_connection/pipeline.svg)](https://gitlab.bsc.es/meep/FPGA_implementations/AlveoU280/fpga_shell/-/commits/develop/ssh_connection)

</div>
- acme
- ariane
- dvino
- ea_demo
- epac
- eprocessor
- pronoc
- sargantana




## 🚀 Features
The shell is meant to be a static perimeter architecture that guarantees that the inside accelerator package can be interchangeable for any other package when meeting a defined I/O interface between the shell and the accelerator package.

### 🎭 EA packages
The list of supported EA packages so far is as follows:
- acme (openpiton framework)
- ariane (openpiton framework)
- dvino
- ea_demo
- epac
- eprocessor
- pronoc
- sargantana

Every EA has a folder  fpga_shell/support with a ea_url.txt file. This file contains the Git URL and the commit SHA. If it is necessary to change the commit SHA to point a specific commit this is the place to modify it.

### 📡 Interfaces
The  FPGA Shell implements the following interfaces:

- PCIe: Establishes communication between FPGA and the host server.
- HBM: High Bandwidth Memory. HBM is the high-performance DRAM interface. It is embedded in the same silicon interposer as the Super Logic Regions (SLR).
- Ethernet: 100Gb Ethernet.
- Aurora: P2P interface.
- DDR4: External Memory.
- Info ROM: Stores and reads information on the configuration of the Shell when booting the project
- UART

### :books: Boards
The supported boards are as follows:
- Alveo U55C
- Alveo U280

## :electric_plug: Prerequisites
- The MEEP Shell is compatible with both Vivado 2021.2. and 2021.1 versions
- It only works on Linux. There is no plan to add Windows support in the middle term.

## 🛠️ Usage
In order to define the interfaces that ought to be active in the Shell, edit <span style="color:green">*accelerator_def.csv*</span> <span style="color:grey"> (./fpga shell/accelerator/piton/design/chipset/meep shell/accelerator def.csv)</span> in the following format:
<br/>
```Bash
INTERFACE_NAME,<diasmbiguation>,XXX,XXX,XXX
```
Where *diasmbiguation* is <span style="color:green">**_yes_**</span> in order to add the component to the Shell, <span style="color:red">**_no_**</span> for it to be absent.<br/>

----

After cloning the repository, in order to create a project:
<br/>Include the EA package by using the correct initialization flag:

```Bash
make initialize LOAD_EA=acme  # Should be used with flag LOAD_EA=<selectedEA>
```
Where *selectedEA* can be any of the supported EA packages: dvino, sargantana, acme, openpiton.


```Bash
make <board>        # In order to choose the FPGA board, where <board>=u55c / u280. 
```

<span style="color:green"> *(Including Openpiton here does not make much sense in my opinion  since it is not an EA, maybe it is the framework for Ariane here?)*. </span>
<br/>

```Bash
make project           # Creates the Vivado project. Generates the FPGA shell around the EA 
```
if you are working with acme, there are different "flavours" that can be generated. <br/>For example
_make project EA_PARAM=acme_
<br/>It will generate a OpePiton project with Lagarto as a core. There are other combinations available.
```Bash
make synthesis         # Synthesizes the project
```
```Bash
make implementation    # Implement the project. Creates the synthesis.dcp if it doesn't exist
```
```Bash
make bitstream         # Generates the bitstream. Creates the synthesis.dcp and/or the implementation.dcp if they don't exist
```


For example:

    make initialize LOAD_EA=acme
    make initialize LOAD_EA=dvino
    make initialize LOAD_EA=sargantana

Every EA has a folder `fpga_shell/support` with a ea_url.txt file. This file contains the Git URL and the commit SHA. If it is necessary to change the commit SHA to point a specific commit this is the place to modify it.

## 3. Vivado project

In order to create a Vivado project, and generate the **FPGA Shell** around the EA.

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

## 4. Typical usage in CLI

Change default board if needed:

    make u280

Update file `ea_url.txt` in `support` folder for your accelerator with required commit. Then clone accelerator repo:

    make initialize LOAD_EA=acme

Make changes in clonned `accelerator` folder or/and any git actions if needed. Run full implementation with additional parameters if needed:

    make all LOAD_EA=acme EA_PARAM=acme_ea_4a

For more details please refer to https://wiki.meep-project.eu/index.php/MEEP_Shell#FPGA_MEEP_Shell_use

## 5. Push with GitLab variables:

    git push -o ci.variable="FPGA_BOARD=u55c" -o ci.variable="CUSTOM_MSG=2x2_withVPU"

    make project EA_PARAMS=pronoc

## 6. Developers guide:

The MEEP FPGA Shell is built around the **sh**, **shell** and **tcl** folders.

The **sh** folder handle some automatic tasks during the whole flow, working closely with Makefiles.

The **tcl** folder joints most of the Vivado calls, procedures and automated scripts.

The **shell** folder is where all the different IPs that can be part of the Shell (depending on the selected configuration) are stored.

IPs are treated individually, in such a way there is no friction between different set ups, meaning that any combination of IPs can be set with no dependency or incompatibility between them. Which such approach, the Shell can be built incrementaly, adding more pieces as they are needed. The only exception to this are the shell_mmcm.tcl file, which configures the clock infrastructure for the
whole design, and the shell_qdma.tcl. The call to these tcls is mandatory, as it will be explained later.

## 7. Bitstreams Naming convention

In order to have a standar method to the bitstream name releases, and the procedure to generate those. There are mandatory rules to use:

### 7.1. ACME_EA

All the bistreams will use the **ACME_EA** with three letters to better identify the main characteristics:

- First letter: to designate the core (A: _Ariane_; H: _Lagarto Hun_)
- Second letter: to identify the accelerator (x: _no accelerator_; V: _VPU_; G: _VPU+SA-HEVC+SA-NN_)
- Thrid letter: to identify the Memory Tile (x: _no MT_, M: _Memory Tile_)

To complete this information, we will add an extra value to each fields:

- **acme_ea_ahbvcm**; where:
  - "a" means the number of cores in the system
  - "b" means the number of vector lanes
  - "c" means the number of MT

### 7.2. Environments to work

We have define two differents environments to generate different bitstream depending of the "environment". There are **Production** and **Test** environment.

## 7.3. Production :rocket:

The production environment will be a monthly release. We will work with:

All use **ProNoC** routers

| Bitstream names                                                  | Description                  | Status                                       |
| :--------------------------------------------------------------- | :--------------------------- | :------------------------------------------- |
| acme_ea_4a                                                       | _golden reference_           | available                                    |
| acme_ea_1h16g1m                                                  |                              | **not** available yet. Pending from MT & SAs |
| acme_ea_4h2v4m                                                   |                              | **not** available yet . Pending from MT      |
| acme_ea_4h2v2m                                                   | (L1.Ariane)                  | **not** available yet [pending from MT]      |
| Meanwhile 2, 3 & 4 are in place we will include a transition one |
| acme_ea_1h16v                                                    | (L1.Ariane)                  | available                                    |
| acme_ea_4h2v                                                     | (L1.Ariane)                  | available                                    |
| acme_ea_1h                                                       | (L1.Ariane) Drivers purposes | available                                    |

:card_box: The FPGA card used here is the **u55c**

There are two ways to execute the pipeline using this environment. By Merge request event :arrow_heading_up: and schedule (monthly, the 1th):clock1:.

The bitstreams generated will be released in https://release.meep-project.eu/nexus/#browse/search/raw

### 7.4. Test :fingers_crossed:

The same ones than before with **OP routers**. This will help to ensure nothing is broken on the way .


## ❗ Available commands

In order to change the default target board:

```Bash
make  <targetBoard>            # Where <targetBoard> = u55c, u280
```
Others:
```Bash
make SmartPlace        # Exahustive search of the best placement strategy (~20hours)
```
```Bash
make reports_synth     # Create synthesis reports: Utilization, timing paths
```
```Bash
make reports_impl      # Create implementation reports: Utilization, timing paths
```
Push with GitLab variables:
```Bash
git push -o ci.variable="FPGA_BOARD=u55c" -o ci.variable="CUSTOM_MSG=2x2_withVPU"
```
```Bash
make project EA_PARAMS=pronoc
```

## 📂 Directory Structure
The MEEP FPGA Shell is built around the sh, shell and tcl folders. <br/>IThe sh folder
handle some automatic tasks during the whole flow, working closely with Makefiles.<br/>I The tcl folder joints most of the Vivado calls, procedures and automated scripts.<br/>I The shell folder is where all the different IPs that can be part of the Shell (depending on the selected configuration) are stored.<br/>I
IPs are treated individually, in such a way there is no friction between different
set ups, meaning that any combination of IPs can be set with no dependency
or incompatibility between them. Which such approach, the Shell can be built
incrementaly, adding more pieces as they are needed. The only exception to this
are the shell_mmcm.tcl file, which configures the clock infrastructure for the
whole design, and the shell_qdma.tcl. The call to these tcls is mandatory, as it
will be explained later.

## :floppy_disk: infoROM information
The ROM hardcoded in the FPGA Shell (infoROM), stores the following information:
- Date of the project generation
- SHA of the Shell
- SHA of the Accelerator
- IDs of the active interfaces

The active interfaces are defined in [accelerator_def](https://wiki.meep-project.eu/index.php/MEEP_Shell#FPGA_SHELL_TCL_building_program "accelerator_def.csv") and parsed in 
[define_shell.sh](https://gitlab.bsc.es/meep/FPGA_implementations/AlveoU280/fpga_shell/-/blob/blanca_ROM/sh/define_shell.sh "define_shell.sh "), where all the aforementioned information gets written in a new file initrom.mem (gets rewritten if it already exists), stored in _misc_ directory inside the parent directory _fpga_shell_. When issuing _make project_, the [Makefile](https://gitlab.bsc.es/meep/FPGA_implementations/AlveoU280/fpga_shell/-/blob/blanca_ROM/Makefile "Makefile")  moves the information stored in _initrom.mem_ into the ip.

### 		:book: Read infoROM 
In order to read from the infoROM, execute [read_inforom.sh](https://gitlab.bsc.es/meep/FPGA_implementations/AlveoU280/fpga_shell/-/blob/blanca_ROM/misc/read_inforom.sh):
```Bash
source read_inforom.sh
```

<div align="center">
    <img src="Images/usage.png" width="500px" alt="<InfoROM output>"/> 

Output of *source read_inforom.sh* 
</div>

#### :microscope: Read by element
```Bash
get date
```
```Bash
get sha shell
```
```Bash
get sha EA
```
```Bash
get EA
```
```Bash
get shell components
```
#### :telescope: Read all at once
```Bash
read all
```
This will automatically kill the process.
<div align="center">
    <img src="Images/inforom_example.png" width="500px" alt="<InfoROM output>"/> 

Output of *read all* command
</div>


[Futher information](https://wiki.meep-project.eu/index.php/MEEP_InfoROM)


## :woman: Authors 
- Alex Kropotov: alex.kropotov@bsc.es
- Bachir Fradj: bachir.fradj@bsc.es
- Blanca Sabater: bsabater@bsc.es
- Daniel J. Mazure: daniel.jimenez2@bsc.es
- Elias Perdomo: elias.perdomo@bsc.es
- Francelly Cano Ladino: francelly.canoladino@bsc.es


## 👷 Partners
**Barcelona Supercomputing Center** - Centro Nacional de Supercomputación (BSC-CNS) :globe_with_meridians:
[Website](https://www.bsc.es "Welcome")
<br/>**University of Zagreb**, Faculty of Electrical Engineering and Computing
:globe_with_meridians: [Website](https://www.fer.unizg.hr/en "Welcome")
<br/>**TÜBITAK BILGEM** Informatics and Information Security Research Center :globe_with_meridians: [Website](https://bilgem.tubitak.gov.tr/en "Welcome")


## :globe_with_meridians: Wiki

For more detailed instructions on how to use this software, visit [project wiki](https://wiki.meep-project.eu/index.php/MEEP_Shell#FPGA_SHELL_TCL_building_program "Wiki").

<br/>
<br/>
<div align="center">
<h2 align="center">🤝 Support</h2>
<p align="center">The MEEP project has received funding from the European High-Performance Computing Joint Undertaking (JU) under grant agreement No 946002. The JU receives support from the European Union’s Horizon 2020 research and innovation programme in Spain, Croatia, Turkey.</p></div>
Including a bitstream with Lagarto Tile: ACME_EA 1Hxx v2.y.z (L1.Tile) with OP routers and ProNoC routers. (Pending)

:card_box: Here we uses the **u280** and **u55c** fpga cards.

If we want to use this environment, we need to use in our _commit message_ **#TestCICD**
