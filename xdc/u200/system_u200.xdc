# Bitstream Configuration                                                 
# ------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 1.8 [current_design]                          
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable [current_design]      
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]             
set_property CONFIG_MODE SPIx4 [current_design]                           
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]             
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8 [current_design]            
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]   
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]          
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]           
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes [current_design]         
# ------------------------------------------------------------------------

#300MHz DDR0 system clock
set_property PACKAGE_PIN AY38             [get_ports  {sysclk0_clk_n} ]            
set_property PACKAGE_PIN AY37             [get_ports  {sysclk0_clk_p} ]            

# 156.25MHz General purpose system clock
set_property PACKAGE_PIN AV19             [ get_ports  {sysclk1_clk_n} ]     
set_property PACKAGE_PIN AU19             [ get_ports  {sysclk1_clk_p} ]     

set_property IOSTANDARD  LVDS              [ get_ports  {sysclk*} ]     


set_property PACKAGE_PIN AL20              [get_ports resetn]   			
set_property IOSTANDARD LVCMOS12           [get_ports resetn]  
