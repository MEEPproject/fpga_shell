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


synth_design
report_qor_assessment -file postsynth.rpt
### Not the real picture here
report_methodology -file methodology.rpt
opt_design
## This one is added by me and need to be investigated
report_design_analysis -timing
report_qor_assessment -file postopt.rpt
### More information here
place_design
report_qor_assessment -file postplace_rqa.rpt
### Good 
phys_opt_design
report_qor_assessment -file postplace_rqa.rpt
### phys_opt_design Not really change the picture 
route_design
report_qor_assessment -file postroute_rqa.rpt
### Too late to get benefit


report_qor_suggestions
### This is run after a design is implemented.
### Analyzes it and apply timing things in the next 
### loop. Touches properties and switches

### In fact, it can be run after everystage, to loop
### over it applying the suggestions.
write_qor_suggestions -file qor.sgs
read_qor_suggestions -file qor.sgs
### And now we can run either
synth_design
### or
opt_design
place_design
phys_opt_design
route_design
delete_qor_suggestions

###Post Place knows SLR cuts.
### Easy way: use it after route_design
### ...but maybe things can be fixed earlier.
### Run it early once and then do it in route_design

### Use always default or explore directive for this
### kind of training. Place_design, phys_opt,
### route_design either all default or all explore

### LAST MILE |WNS| < -0.100
### After route_design, after going through the QOR flow,
read_checkpoint -incremental
place_design
phys_opt_design
route_design
### 20% success

### This doesn't work in Vitis, works in Vivado only

