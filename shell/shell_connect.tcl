## Connect Reset Block clk
connect_bd_net [get_bd_pins rst_ea_domain/slowest_sync_clk] [get_bd_pins clk_wiz_1/CLK0]

## Create an smartconnect block to translate HBM-User Inft protocols -HBM is AXI3-
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.HAS_ARESETN {0}] [get_bd_cells smartconnect_0]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins hbm_0/SAXI_08]
connect_bd_net [get_bd_pins smartconnect_0/aclk] [get_bd_pins clk_wiz_1/CLK0]


## IF PCIe has a direct access to the main memory, open an HBM channel for it
## Actually, we are using an AXI interconnect so we rely on address editor. 
## Not optimal