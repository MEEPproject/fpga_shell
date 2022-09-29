# Bitstream Configuration                                                 
# ------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 1.8 [current_design]                          
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable [current_design]      
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]             
set_property CONFIG_MODE SPIx4 [current_design]                           
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]             
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]            
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]   
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]          
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]           
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes [current_design]         
# ------------------------------------------------------------------------

set_property PACKAGE_PIN BJ44               [get_ports  {sysclk0_clk_n} ]            
set_property PACKAGE_PIN BJ43               [get_ports  {sysclk0_clk_p} ]            

set_property PACKAGE_PIN BJ6                [get_ports  {sysclk1_clk_n} ]     
set_property PACKAGE_PIN BH6                [get_ports  {sysclk1_clk_p} ]     

set_property IOSTANDARD  LVDS               [get_ports  {sysclk*} ]     


set_property PACKAGE_PIN L30                [get_ports resetn ]   			
set_property IOSTANDARD LVCMOS18            [get_ports resetn ]  

create_clock -period 10.000 -name SYSCLK_0  [get_ports sysclk0_clk_p ]

# The clock below doesn't need to be created as it is fixed to the MMCM and it creates the constraint itself
#create_clock -period 10.000 -name SYSCLK_1      [get_ports sysclk1_clk_p]
