## Connect Reset Block clk

putdebugs "HBM Name: $HBMClkNm"

## TODO: Handle processor system reset
### Create a list of connections belonging to a interface

### HBM Interface, list of resets connections
#foreach Number of HBM Channels
connect_bd_net [get_bd_pins rst_ea_$HBMClkNm/peripheral_aresetn] [get_bd_pins hbm_0/AXI_08_ARESET_N]
connect_bd_net [get_bd_pins rst_ea_$HBMClkNm/peripheral_aresetn] [get_bd_pins axi_protocol_convert_0/aresetn]
connect_bd_net [get_bd_pins rst_ea_$HBMClkNm/peripheral_aresetn] [get_bd_pins axi_dwidth_converter_0/s_axi_aresetn]


#foreach Number of APB interfaces, one per stack
connect_bd_net [get_bd_pins hbm_0/APB_0_PRESET_N] [get_bd_pins rst_ea_$HBMClkNm/peripheral_aresetn]

### UART
#connect_bd_net [get_bd_pins rst_ea_domain/peripheral_aresetn] [get_bd_pins axi_uart16550_0/s_axi_aresetn]
