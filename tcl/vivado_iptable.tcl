# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Solderpad Hardware License v 2.1 (the "License");
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
# 
#     http://www.solderpad.org/licenses/SHL-2.1
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Daniel J.Mazure, BSC-CNS
# Date: 22.02.2022
# Description: 



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
		set HBMaddrWidth "33"
	}
	u55c {
		set HBM_AXI_LABEL "_8HI"
		set HBMDensity "16GB"
		set HBMaddrWidth "34"
	}
}

set MEEPUart "meep-project.eu:MEEP:pulp_uart:1.0"
set XilinxUart "xilinx.com:ip:axi_uart16550:2.0"

