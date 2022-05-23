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


### Others
assign_bd_address
#set_property offset 0x00000000 [get_bd_addr_segs {qdma_0/M_AXI_LITE/SEG_axi_gpio_0_Reg}]
set_property offset 0x00000000 [get_bd_addr_segs {qdma_0/M_AXI_LITE/SEG_axi_gpio_0_Reg}]
validate_bd_design
save_bd_design
