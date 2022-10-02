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
set_property PACKAGE_PIN BL10             [get_ports  {sysclk0_clk_n} ]            
set_property PACKAGE_PIN BK10             [get_ports  {sysclk0_clk_p} ]            

set_property PACKAGE_PIN BK44             [get_ports  {sysclk1_clk_n} ]     
set_property PACKAGE_PIN BK43             [get_ports  {sysclk1_clk_p} ]     

#set_property PACKAGE_PIN F23              [get_ports  {sysclk2_clk_n} ] 
#set_property PACKAGE_PIN F24              [get_ports  {sysclk2_clk_p} ] 


set_property IOSTANDARD  LVDS              [ get_ports  {sysclk*} ]     

set_property PACKAGE_PIN BG45              [get_ports resetn] ;# Bank  65 VCCO - VCC1V8   - IO_L18N_T2U_N11_AD2N_D13_65
set_property IOSTANDARD  LVCMOS18          [get_ports resetn] ;# Bank  65 VCCO - VCC1V8   - IO_L18N_T2U_N11_AD2N_D13_65


#Clocks 0, 1 and 2 are 2,3, and 4 in the u55c master file:
#set_property PACKAGE_PIN F23     [get_ports "SYSCLK4_N"] ;# Bank  72 VCCO - VCC1V8   - IO_L11N_T1U_N9_GC_72_F23
#set_property PACKAGE_PIN F24     [get_ports "SYSCLK4_P"] ;# Bank  72 VCCO - VCC1V8   - IO_L11P_T1U_N8_GC_72_F24
#set_property PACKAGE_PIN BK44     [get_ports "SYSCLK3_N"] ;# Bank  65 VCCO - VCC1V8   - IO_L11N_T1U_N9_GC_A11_D27_65
#set_property PACKAGE_PIN BK43     [get_ports "SYSCLK3_P"] ;# Bank  65 VCCO - VCC1V8   - IO_L11P_T1U_N8_GC_A10_D26_65
#set_property PACKAGE_PIN BL10     [get_ports "SYSCLK2_N"] ;# Bank  68 VCCO - VCC1V8   - IO_L11N_T1U_N9_GC_68
#set_property PACKAGE_PIN BK10     [get_ports "SYSCLK2_P"] ;# Bank  68 VCCO - VCC1V8   - IO_L11P_T1U_N8_GC_68

#IMPORTANT: sysclk0 is sysclk2 in the u55c master xdc file. sysclk1 is sysclk3
#For u280 compatibility reasons

create_clock -period 10.000 -name SYSCLK_2      [get_ports sysclk0_clk_p]
#create_clock -period 10.000 -name SYSCLK_3      [get_ports sysclk1_clk_p] 
#create_clock -period 10.000 -name sysclk4      [get_ports sysclk2_clk_p]
