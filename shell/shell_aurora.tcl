set AuroraClkNm [dict get $Auroraentry SyncClk Label]
set AuroraFreq  [dict get $Auroraentry SyncClk Freq]
set Auroraname  [dict get $Auroraentry SyncClk Name]
set Auroraintf  [dict get $Auroraentry IntfLabel]
set Aurorainitfile [dict get $Auroraentry InitFile]

set AuroraaddrWidth [dict get $Auroraentry AxiAddrWidth]
set AuroradataWidth [dict get $Auroraentry AxiDataWidth]
set AuroraidWidth   [dict get $Auroraentry AxiIdWidth]
set AuroraUserWidth [dict get $Auroraentry AxiUserWidth]


### Initialize the IPs
putmeeps "Packaging Aurora IP..."
exec vivado -mode batch -nolog -nojournal -notrace -source ./ip/aurora_dma/tcl/gen_project.tcl -tclargs $g_board_part
putmeeps "... Done."
update_ip_catalog -rebuild

source $g_root_dir/ip/aurora_dma/tcl/project_options.tcl

create_bd_cell -type ip -vlnv meep-project.eu:MEEP:axi_Aurora:$g_ip_version axi_Aurora_0

## Create the Shell interface to the RTL
## CAUTION: The user can't specify USER, QOS and REGION signal for this interface
## This means those signals can't be in the module definition file

  # Create interface ports
  set Aurora_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $Auroraintf ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH $AuroraaddrWidth \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH $AuroradataWidth \
   CONFIG.FREQ_HZ $AuroraFreq \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH $AuroraidWidth \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $Aurora_axi

### Set Base Addresses to peripheral
# Aurora
set AurorabaseAddr [dict get $Auroraentry BaseAddr]
set AuroraMemRange [expr {2**$AuroraaddrWidth/1024}]

putdebugs "Base Addr Aurora: $AurorabaseAddr"
putdebugs "Mem Range Aurora: $AuroraMemRange"


set_property offset $AurorabaseAddr [get_bd_addr_segs $Auroraintf/SEG_axi_bram_ctrl_0_Mem0]
set_property range ${AuroraMemRange}K [get_bd_addr_segs $Auroraintf/SEG_axi_bram_ctrl_0_Mem0]




