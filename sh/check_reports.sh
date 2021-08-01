#!/bin/bash

if [ ! -d "reports" ]; then
       printf "Reports directory doesn't exist!\n"	
       exit 1
fi

ret=0

TimingError="`grep -rn reports -e 'The design failed to meet the timing requirements' || true`"

if [ -n "$TimingError" ]; then	
    echo "The design didn't met timing. Validation will fail"
fi


CriticalWarnings="`grep -rn reports -e 'Critical Warning' | awk '$5 > "0" {print $5,$6,$7}'`"

if [ -n "$CriticalWarnings" ]; then	
	echo "The desing contains Critical Warnings. Remove them to pass validation"
	#exit 1
	ret=1
else
    echo "No Critical Warnings in the design"
fi


errors="`grep -rn reports -e 'Critical Warning' | awk '$9 > "0" {print $9,$10}'`"

#echo "Errors grep returned <$errors>"

if [ -n "$errors" ]; then
	echo "The design contains Errors. Remove them to pass validation"
	#exit 1
	ret=1
else
    echo "No errors found in the design"
fi

if [ "$ret" -eq 1 ]; then
    echo "Report validation failed"
    exit 1
else
    echo "Report validation passed"
    #exit 0
fi	


#exit 0
