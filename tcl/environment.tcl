#script_version 0
set g_vivado_version 2020.1 
set g_fpga_part xcvu47p-fsvh2892-2L-e
set g_board_part u55c
#set g_board_part "u55c"
#u55c "xcvu47p-fsvh2892-2L-e"
set g_current_vivado_version [version -short] 
set g_project_name system      
set g_root_dir    [pwd]                     
set g_project_dir ${g_root_dir}/project    
set g_design_name ${g_project_name}       
set g_top_module  ${g_root_dir}/src/${g_project_name}_top.vhd
set g_useBlockDesign Y 	  
set g_rtl_ext sv 	 
set g_number_of_jobs 4				  

