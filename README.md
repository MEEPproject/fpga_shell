
<div align="center">
    <img src="Images/meep-logo-symbol.png" width="200px" alt="<MEEP logo>"/> 


<br/>
<h1 align="center">MEEP Shell 

<br/>
<br/>
</div>





## 🚀 Features
The shell is meant to be a static perimeter architecture that guarantees that the inside accelerator package can be interchangeable for any other package when meeting a defined I/O interface between the shell and the accelerator package.

The list of supported EA packages so far is as follows:
- dvino
- sargantana
- acme (openpiton framework)

The  FPGA Shell implements the following interfaces:

- PCIe: Establishes communication between FPGA and the host server.
- HBM: High Bandwidth Memory. HBM is the high-performance DRAM interface. It is embedded in the same silicon interposer as the Super Logic Regions (SLR).
- Ethernet: 100Gb Ethernet.
- Aurora: P2P interface.
- DDR4: External Memory.
- Boot ROM: Stores and reads information on the configuration of the Shell when booting the project
- UART

## :electric_plug: Prerequisites
- The MEEP Shell needs to be used with Vivado 2021.2. 
- The board files for U280/U55C don't need to be installed.
- It only works on Linux. There is no plan to add Windows support in the middle term.

## 🛠️ Usage
In order to define the interfaces that ought to be active in the Shell, edit <span style="color:green">*accelerator_def.csv*</span> <span style="color:grey"> (./git repo/fpga shell/accelerator/piton/design/chipset/meep shell/accelerator def.csv)</span> in the following format:
<br/>
```Bash
INTERFACE_NAME,<diasmbiguation>,XXX,XXX,XXX
```
Where *diasmbiguation* is <span style="color:green">**_yes_**</span> in order to add the component to the Shell, <span style="color:red">**_no_**</span> for it to be absent.<br/>

----

After cloning the repository, in order to create a project:
<br/>Include the EA package by using the correct initialization flag:

```Bash
make initialize        # Should be used with flag LOAD_EA=<selectedEA>
```
Where *selectedEA* can be any of the supported EA packages: dvino, sargantana, acme, openpiton.

<span style="color:green"> *(Including Openpiton here does not make much sense in my opinion  since it is not an EA, maybe it is the framework for Ariane here?)*. </span>
<br/>

```Bash
make binaries          # It generates the binaries 
```
```Bash
make project           # Creates the Vivado project. Generates the FPGA shell around the EA 
```
```Bash
make synthesis         # Synthesizes the project
```
```Bash
make implementation    # Implement the project. Creates the synthesis.dcp if it doesn't exist
```
```Bash
make bitstream         # Generates the bitstream. Creates the synthesis.dcp and/or the implementation.dcp if they don't exist
```





## ❗ Available commands

In order to change the default target board:

```Bash
make  <targetBoard>            # Where <targetBoard> = u55c, u280, vcu128
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
The MEEP FPGA Shell is built around the sh, shell and tcl folders. The sh folder
handle some automatic tasks during the whole flow, working closely with Makefiles. The tcl folder joints most of the Vivado calls, procedures and automated scripts. The shell folder is where all the different IPs that can be part of the Shell (depending on the selected configuration) are stored.
IPs are treated individually, in such a way there is no friction between different
set ups, meaning that any combination of IPs can be set with no dependency
or incompatibility between them. Which such approach, the Shell can be built
incrementaly, adding more pieces as they are needed. The only exception to this
are the shell_mmcm.tcl file, which configures the clock infrastructure for the
whole design, and the shell_qdma.tcl. The call to these tcls is mandatory, as it
will be explained later.

## 👷 Partners
**Barcelona Supercomputing Center** - Centro Nacional de Supercomputación (BSC-CNS) :globe_with_meridians:
[Website](https://www.bsc.es "Welcome")
<br/>**University of Zagreb**, Faculty of Electrical Engineering and Computing
:globe_with_meridians: [Website](https://www.fer.unizg.hr/en "Welcome")
<br/>**TÜBITAK BILGEM** Informatics and Information Security Research Center :globe_with_meridians: [Website](https://bilgem.tubitak.gov.tr/en "Welcome")



## :woman: Authors 
- Alex Kropotov: alex.kropotov@bsc.es
- Bachir Fradj: bachir.fradj@bsc.es
- Blanca Sabater: bsabater@bsc.es
- Daniel J. Mazure: daniel.jimenez2@bsc.es
- Elias Perdomo: elias.perdomo@bsc.es
- Francelly Cano Ladino: francelly.canoladino@bsc.es


## :globe_with_meridians: Wiki

For more detailed instructions on how to use this software, visit [project wiki](https://wiki.meep-project.eu/index.php/MEEP_Shell#FPGA_SHELL_TCL_building_program "Wiki").


<h2 align="center">🤝 Support</h2>
<p align="center">The MEEP project has received funding from the European High-Performance Computing Joint Undertaking (JU) under grant agreement No 946002. The JU receives support from the European Union’s Horizon 2020 research and innovation programme in Spain, Croatia, Turkey.</p>
