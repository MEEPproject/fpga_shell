#!/bin/bash

#we need to write here the .gitsubmodules file, so this process receives that
#label as a parameter and the ci/cd can proceed. The accelerator is received.
#Then, call <accelerator_init.sh>, to trigger the needed processes.

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters, terminating"
	echo "Usage: generate.sh <accelerator_repo>"
	return -1
fi

bash -x sh/gitsubmodules.sh $1 $2
#Generic call to accelerator conf script. It should be meep_shell/accelerator_init.sh
cd accelerator
bash -x meep_shell/accelerator_init.sh
cd ..
#Make a make inside DVINO
