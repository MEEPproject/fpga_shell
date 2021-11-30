  
  
  set pci_express_x16 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pci_express_x16 ]

  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]

   
  set pcie_perstn [ create_bd_port -dir I -type rst pcie_perstn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pcie_perstn
  set resetn [ create_bd_port -dir I -type rst resetn ]


  #Depends on the board
  set sysclk1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sysclk1 ]
  
  
 
  # Create instance: qdma_0, and set properties
  set qdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:qdma:4.0 qdma_0 ]
  set_property -dict [ list \
   CONFIG.MAILBOX_ENABLE {true} \
   CONFIG.PF0_SRIOV_CAP_INITIAL_VF {4} \
   CONFIG.PF1_MSIX_CAP_TABLE_SIZE_qdma {000} \
   CONFIG.PF1_SRIOV_CAP_INITIAL_VF {0} \
   CONFIG.PF1_SRIOV_FIRST_VF_OFFSET {0} \
   CONFIG.PF2_MSIX_CAP_TABLE_SIZE_qdma {000} \
   CONFIG.PF2_SRIOV_CAP_INITIAL_VF {0} \
   CONFIG.PF2_SRIOV_FIRST_VF_OFFSET {0} \
   CONFIG.PF3_MSIX_CAP_TABLE_SIZE_qdma {000} \
   CONFIG.PF3_SRIOV_CAP_INITIAL_VF {0} \
   CONFIG.PF3_SRIOV_FIRST_VF_OFFSET {0} \
   CONFIG.SRIOV_CAP_ENABLE {true} \
   CONFIG.SRIOV_FIRST_VF_OFFSET {4} \
   CONFIG.barlite_mb_pf0 {1} \
   CONFIG.barlite_mb_pf1 {0} \
   CONFIG.barlite_mb_pf2 {0} \
   CONFIG.barlite_mb_pf3 {0} \
   CONFIG.dma_intf_sel_qdma {AXI_MM} \
   CONFIG.en_axi_st_qdma {false} \
   CONFIG.flr_enable {true} \
   CONFIG.mode_selection {Advanced} \
   CONFIG.pcie_blk_locn {PCIE4C_X1Y0} \
   CONFIG.select_quad {GTY_Quad_227} \
   CONFIG.pf0_ari_enabled {true} \
   CONFIG.pf0_bar0_prefetchable_qdma {true} \
   CONFIG.pf0_bar2_prefetchable_qdma {true} \
   CONFIG.pf1_bar0_prefetchable_qdma {true} \
   CONFIG.pf1_bar2_prefetchable_qdma {true} \
   CONFIG.pf1_msix_enabled_qdma {false} \
   CONFIG.pf2_bar0_prefetchable_qdma {true} \
   CONFIG.pf2_bar2_prefetchable_qdma {true} \
   CONFIG.pf2_msix_enabled_qdma {false} \
   CONFIG.pf3_bar0_prefetchable_qdma {true} \
   CONFIG.pf3_bar2_prefetchable_qdma {true} \
   CONFIG.pf3_msix_enabled_qdma {false} \
   CONFIG.testname {mm} \
   CONFIG.tl_pf_enable_reg {1} \
 ] $qdma_0


 # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $util_ds_buf

 
  # Create instance: vdd_0, and set properties (tie to vdd ready pcie signal)
  set vdd_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 vdd_0 ]
  
    # Create interface connections
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  #connect_bd_intf_net -intf_net qdma_0_M_AXI_LITE [get_bd_intf_pins axi_periph/S00_AXI] [get_bd_intf_pins qdma_0/M_AXI_LITE]
  connect_bd_intf_net -intf_net qdma_0_pcie_mgt [get_bd_intf_ports pci_express_x16] [get_bd_intf_pins qdma_0/pcie_mgt]
  connect_bd_net -net pcie_perstn_1 [get_bd_ports pcie_perstn] [get_bd_pins qdma_0/soft_reset_n] [get_bd_pins qdma_0/sys_rst_n]
 # connect_bd_net -net resetn_1 [get_bd_ports resetn] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins rst_dvino_alveo_300M/ext_reset_in]
  connect_bd_net -net vdd_0_dout [get_bd_pins qdma_0/qsts_out_rdy] [get_bd_pins qdma_0/tm_dsc_sts_rdy] [get_bd_pins vdd_0/dout]
  connect_bd_net -net util_ds_buf_IBUF_DS_ODIV2 [get_bd_pins qdma_0/sys_clk] [get_bd_pins util_ds_buf/IBUF_DS_ODIV2]
  connect_bd_net -net util_ds_buf_IBUF_OUT [get_bd_pins qdma_0/sys_clk_gt] [get_bd_pins util_ds_buf/IBUF_OUT]


###############################################################
# Set MMCM using the clocks extracted from the definition file
###############################################################

set i 1
set n 0
set ConfMMCMString " "
# 1GHz, arbitrarily High
set slowestSyncCLK 1000000000
set APBclkCandidate ""

foreach clkObj $ClockList {

	### Spaces at the end of a string are necessary when using append
	if { $i > 1 } {
		set ConfMMCM "CONFIG.CLKOUT${i}_USED true "
		append ConfMMCMString "$ConfMMCM"
	}
	set ClkFreq  [dict get $clkObj ClkFreq]
	set ClkFreqMHz [expr $ClkFreq/1000000 ]
	putmeeps "Configuring MMCM output $i: ${ClkFreqMHz}MHz"
	set ConfMMCM "CONFIG.CLKOUT${i}_REQUESTED_OUT_FREQ ${ClkFreqMHz} "
	append ConfMMCMString "$ConfMMCM"
	
	set ConfMMCM "CONFIG.CLK_OUT${i}_PORT CLK${n} "
	append ConfMMCMString "$ConfMMCM"
	incr i
	incr n
	
	#Get the slowest clock and check if there is any below
	#100MHz. If it doesn't, it needs to be created to source
	#the HBM APB port.
	
	set currentClk [dict get $clkObj ClkFreq]
	
	if { $currentClk < $slowestSyncCLK } {
		set slowestSyncCLKname [dict get $clkObj Name]
		set slowestSyncCLK $currentClk
		if { 50000000 <= $currentClk && $currentClk <= 100000000} {
			set APBclkCandidate [dict get $clkObj Name]
		}
	}
}

putmeeps "Slowest CLK: $slowestSyncCLKname, APBcandidate: $APBclkCandidate"

### An APB clock is added to the list if no candidate is found
set APBclk ""

if { $APBclkCandidate ne "" } {
	
	set APBclk $APBclkCandidate
	
	putmeeps "APB CLK: $APBclk"

} else {
	set numClk [expr [llength ClockList] +2]
	set d_clock [dict create Name CLK${numClk}]
	#a 50MHz clock needs to be created
	# ClockList
	dict set d_clock ClkNum  CLK${numClk}
	dict set d_clock ClkFreq 50000000
	dict set d_clock ClkName APBclk
	
	set APBclk "CLK[expr $numClk -1]"
	
	set ClockList [lappend ClockList $d_clock]	

	putdebugs "Adding APB Clk to the list: $ClockList"
	
	set ConfMMCM "CONFIG.CLKOUT${numClk}_USED true "
	append ConfMMCMString "$ConfMMCM"
	
	set ConfMMCM "CONFIG.CLKOUT${numClk}_REQUESTED_OUT_FREQ 50 "
	append ConfMMCMString "$ConfMMCM"
	
	set ConfMMCM "CONFIG.CLK_OUT${numClk}_PORT CLK[expr [llength ClockList]+1] "
	append ConfMMCMString "$ConfMMCM"		
	
}
	
   set ClockParamList [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
   CONFIG.USE_RESET {false} \
   CONFIG.PRIM_IN_FREQ {100.000} \
   CONFIG.USE_LOCKED {true} \
   ]

  append ClockParamList $ConfMMCMString
  
  putdebugs "MMCM configuration: $ClockParamList"

  #Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
  set_property -dict $ClockParamList $clk_wiz_1
    
  connect_bd_intf_net [get_bd_intf_ports sysclk1] [get_bd_intf_pins clk_wiz_1/CLK_IN1_D]
 
  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ea_domain
  connect_bd_net [get_bd_ports resetn] [get_bd_pins rst_ea_domain/ext_reset_in]
  
  
 save_bd_design  






