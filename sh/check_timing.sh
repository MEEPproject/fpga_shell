#!/bin/bash
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


#!/bin/bash

if [ ! -d "reports" ]; then
       printf "Reports directory doesn't exist!\n"
       exit 1
fi

ret=0

#If this message is found, variable is NOT empty and the next if marks the error
TimingError="`grep -rn reports -e 'Timing constraints are not met' || true`"

if [ -n "$TimingError" ]; then
    echo "The design didn't met timing. Validation will fail"
    ret=1
fi

if [ "$ret" -eq 1 ]; then
    echo "Report validation failed"
    exit 1
else
    echo "Report validation passed"
    #exit 0
fi

