#script_version 1 
set g_vivado_version 2020.1 
set g_fpga_part xcu280-fsvh2892-2L-e
set g_board_part u280
set g_current_vivado_version [version -short] 
set g_project_name system      
set g_root_dir    [pwd]                     
set g_project_dir ${g_root_dir}/project    
set g_accel_dir ${g_root_dir}/accelerator
set g_design_name ${g_project_name}       
set g_top_module  ${g_root_dir}/src/${g_project_name}_top.vhd
set g_useBlockDesign Y 	  
set g_rtl_ext sv 	 
set g_number_of_jobs 4				  

#################################################################
# This list the shell capabilities. Add more interfaces when they 
# are ready to be implemented. XDC FPGA Board file could be used.
#################################################################
set ShellInterfacesList [list PCIE DDR4 HBM AURORA ETHERNET UART BROM]

## TODO: Add JTAG?
## List here the physical interfaces. Lowercase as they are connected
## to file names. 
set PortInterfacesList  [list pcie ddr4 aurora ethernet uart ]
set PCIeDMA "yes"

##################################################################
# Enable debug messages
##################################################################
set DebugEnable "True"
