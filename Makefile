ROOT_DIR    =  $(PWD)
TCL_DIR     =  $(ROOT_DIR)/tcl
SH_DIR	    =  $(ROOT_DIR)/sh
DEF_FILE    =  $(ROOT_DIR)/ea_url.txt
EA_REPO     =  EMULATED_ACCELERATOR_REPO
EA_SHA      =  EMULATED_ACCELERATOR_SHA
EA_GIT_URL  = `grep -m 1 $(DEF_FILE) -e $(EA_REPO) | awk -F ' ' '$$2 {print $$2}' `
EA_GIT_SHA  = `grep -m 1 $(DEF_FILE) -e $(EA_SHA)  | awk -F ' ' '$$2 {print $$2}' `
EA_DIR      =  $(ROOT_DIR)/accelerator
DATE        =  `date +'%a %b %e %H:%M:$S %Z %Y'`
ACCEL_DIR   =  $(ROOT_DIR)/accelerator
SYNTH_DCP   =  $(ROOT_DIR)/dcp/synthesis.dcp 
REPORT_DIR  =  $(ROOT_DIR)/reports
YAML_FILE   =  $(ROOT_DIR)/.gitlab-ci.yml
PROJECT_DIR =  $(ROOT_DIR)/project

.PHONY: clean clean_shell clean_accelerator clean_synthesis clean_implementation ci_cd

#.DEFAULT_GOAL := initialize
all: binaries vivado synthesis implementation bitstream validate

ci_cd: $(YAML_FILE)
	# Edit the YAML file to update the URLs
	$(SH_DIR)/extract_url.sh

initialize:
	EA_GIT_URL=$$(grep -m 1 $(DEF_FILE) -e $(EA_REPO) | awk -F ' ' '$$2 {print $$2}' ) ;\
	$(ROOT_DIR)/init_project.sh $$EA_GIT_URL $(EA_GIT_SHA) ;\

binaries: $(ACCEL_DIR)
	$(SH_DIR)/accelerator_build.sh

vivado: 
	/opt/Xilinx/Vivado/2020.1/settings64.sh
	$(ROOT_DIR)/init_vivado.sh 

synthesis: vivado
	$(SH_DIR)/run_synthesis.sh

implementation: $(SYNTH_DCP)
	$(SH_DIR)/run_implementation.sh
	
bitstream: $(IMPL_DCP)
	$(SH_DIR)/run_bitstream.sh
	
validate: $(REPORT_DIR)
	$(SH_DIR)/check_reports.sh

clean: 
	rm -rf project dcp reports accelerator src binaries
	
clean_ci_cd:
	git checkout $(DEF_FILE)
	
clean_shell:
	rm -rf project src
	
clean_accelerator:
	rm -rf accelerator

clean_synthesis:	
	rm -rf dcp/*

clean_implementation:
	rm -rf dcp/implementation.dcp reports


