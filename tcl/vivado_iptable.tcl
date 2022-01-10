
switch $g_vivado_version {
	2020.1 {
		#body
		set meep_util_ds_buf "xilinx.com:ip:util_ds_buf:2.1"
	}
	2021.2 {
		set meep_util_ds_buf "xilinx.com:ip:util_ds_buf:2.2"
	}
}

switch $g_board_part {
	u280 {
		set HBM_AXI_LABEL ""
		set HBMDensity "8GB"
	}
	u55c {
		set HBM_AXI_LABEL "_8HI"
		set HBMDensity "16GB"
	}
}
