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

