ROOT_DIR   =  $(PWD)
TCL_DIR    =  $(ROOT_DIR)/tcl
EA_REPO   :=  ${shell grep -rn -m 1 'ea_url.txt' -e 'EMULATED_ACCELERATOR_REPO' | awk -F ' ' '$$3 {print $$3}'}
EA_SHA    :=  ${shell grep -rn -m 1 'ea_url.txt' -e 'EMULATED_ACCELERATOR_SHA' | awk -F ' ' '$$3 {print $$3}'}
EA_DIR     =  $(ROOT_DIR)/accelerator
DATE       =  `date +'%a %b %e %H:%M:$S %Z %Y'`
SYNTH_DCP  =  $(ROOT_DIR)/dcp/synthesis.dcp 
REPORT_DIR =  $(ROOT_DIR)/reports

.PHONY: clean clean_shell clean_accelerator clean_synthesis clean_implementation 

#.DEFAULT_GOAL := initialize
all: binaries vivado synthesis implementation bitstream validate

initialize:
	./init_project.sh '$(EA_REPO) $(EA_SHA)'
	mkdir -p binaries


binaries: initialize
	./sh/accelerator_build.sh

vivado: initialize
	cp -r accelerator/meep_shell/binaries/* binaries	
	./init_vivado.sh 

synthesis: initialize
	./sh/run_synthesis

implementation: $(SYNTH_DCP)
	./sh/run_implementation
	
bitstream: $(IMPL_DCP)
	./sh/run_bitstream.sh
	
validate: $(REPORT_DIR)
	./sh/check_reports.sh

clean: 
	rm -rf project dcp reports accelerator src
	
clean_shell:
	rm -rf project src
	
clean_accelerator:
	rm -rf accelerator

clean_synthesis:	
	rm -rf dcp/*

clean_implementation:
	rm -rf dcp/implementation.dcp reports


