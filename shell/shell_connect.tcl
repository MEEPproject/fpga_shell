## Connect Reset Block clk


putdebugs "Slowest CLK: $slowestSyncCLK"

connect_bd_net [get_bd_pins rst_ea_domain/slowest_sync_clk] [get_bd_pins clk_wiz_1/$slowestSyncCLKname]


## TODO: Handle processor system reset

connect_bd_net [get_bd_pins rst_ea_domain/peripheral_aresetn] [get_bd_pins hbm_0/AXI_08_ARESET_N]
connect_bd_net [get_bd_pins hbm_0/APB_0_PRESET_N] [get_bd_pins rst_ea_domain/peripheral_aresetn]
