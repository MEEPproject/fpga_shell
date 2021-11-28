## Connect Reset Block clk
connect_bd_net [get_bd_pins rst_ea_domain/slowest_sync_clk] [get_bd_pins clk_wiz_1/CLK0]

## Create an smartconnect block to translate HBM-User Inft protocols -HBM is AXI3-
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0

set_property -dict [list CONFIG.NUM_SI {1} CONFIG.HAS_ARESETN {0}] [get_bd_cells smartconnect_0]

connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins hbm_0/SAXI_08]
connect_bd_net [get_bd_pins smartconnect_0/aclk] [get_bd_pins clk_wiz_1/CLK0]
connect_bd_intf_net [get_bd_intf_ports mem_nasti] [get_bd_intf_pins smartconnect_0/S00_AXI]
set_property CONFIG.ASSOCIATED_BUSIF {mem_nasti} [get_bd_ports /clk_sys]
set_property CONFIG.ASSOCIATED_BUSIF {io_nasti_uart} [get_bd_ports /clk_sys]




## IF PCIe has a direct access to the main memory, open an HBM channel for it
## Actually, we are using an AXI interconnect so we rely on address editor. 
## Not optimal

create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_1
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.HAS_ARESETN {0}] [get_bd_cells smartconnect_1]


connect_bd_intf_net [get_bd_intf_pins qdma_0/M_AXI] [get_bd_intf_pins smartconnect_1/S00_AXI]
connect_bd_net [get_bd_pins qdma_0/axi_aclk] [get_bd_pins smartconnect_1/aclk]

set_property -dict [list CONFIG.USER_SAXI_00 {true}] [get_bd_cells hbm_0]
connect_bd_intf_net [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins hbm_0/SAXI_00]
connect_bd_net [get_bd_pins qdma_0/axi_aclk] [get_bd_pins hbm_0/AXI_00_ACLK]
connect_bd_net [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins hbm_0/AXI_00_ARESET_N]


## TODO: Handle processor system reset

connect_bd_net [get_bd_pins rst_ea_domain/peripheral_aresetn] [get_bd_pins hbm_0/AXI_08_ARESET_N]
connect_bd_net [get_bd_pins hbm_0/APB_0_PRESET_N] [get_bd_pins rst_ea_domain/peripheral_aresetn]
