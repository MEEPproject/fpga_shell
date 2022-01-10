set AuroraClkNm [dict get $AURORAentry SyncClk Label]
set AuroraFreq  [dict get $$AURORAentry SyncClk Freq]
set Auroraname  [dict get $$AURORAentry SyncClk Name]
set Auroraintf  [dict get $$AURORAentry IntfLabel]

set AuroraaddrWidth [dict get $$AURORAentry AxiAddrWidth]
set AuroradataWidth [dict get $$AURORAentry AxiDataWidth]
set AuroraidWidth   [dict get $$AURORAentry AxiIdWidth]
set AuroraUserWidth [dict get $$AURORAentry AxiUserWidth]


### Initialize the IPs
putmeeps "Packaging Aurora IP..."
exec vivado -mode batch -nolog -nojournal -notrace -source ./ip/aurora_dma/tcl/gen_project.tcl -tclargs $g_board_part
putmeeps "... Done."
update_ip_catalog -rebuild

source $g_root_dir/ip/aurora_dma/tcl/project_options.tcl

create_bd_cell -type ip -vlnv meep-project.eu:MEEP:MEEP_aurora_dma:$g_ip_version aurora_dma_0

### Set Base Addresses to peripheral
# Aurora
set AurorabaseAddr [dict get $AURORAentry BaseAddr]
set AuroraMemRange [expr {2**$AuroraaddrWidth/1024}]

putdebugs "Base Addr Aurora: $AurorabaseAddr"
putdebugs "Mem Range Aurora: $AuroraMemRange"


set_property offset $AurorabaseAddr [get_bd_addr_segs $Auroraintf/SEG_aurora_dma_0_Mem0]
set_property range ${AuroraMemRange}K [get_bd_addr_segs $Auroraintf/SEG_aurora_dma_0_Mem0]




