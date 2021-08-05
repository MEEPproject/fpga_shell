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
IMPL_DCP    =  $(ROOT_DIR)/dcp/implementation.dcp 
REPORT_DIR  =  $(ROOT_DIR)/reports
YAML_FILE   =  $(ROOT_DIR)/.gitlab-ci.yml
PROJECT_DIR =  $(ROOT_DIR)/project
VIVADO_VER  :=  "2020.1"
VIVADO_PATH := /opt/Xilinx/Vivado/$(VIVADO_VER)/bin/vivado
VIVADO_OPT  = -mode batch -nolog -nojournal -notrace -source

.PHONY: clean clean_shell clean_accelerator clean_synthesis clean_implementation ci_cd

#.DEFAULT_GOAL := initialize
all: binaries vivado synthesis implementation bitstream validate

ci_cd: $(YAML_FILE)
	# Edit the YAML file to update the URLs
	$(SH_DIR)/extract_url.sh

initialize: clean
	EA_GIT_URL=$$(grep -m 1 $(DEF_FILE) -e $(EA_REPO) | awk -F ' ' '$$2 {print $$2}' ) ;\
	$(ROOT_DIR)/init_project.sh $$EA_GIT_URL $(EA_GIT_SHA) ;\

binaries: $(ACCEL_DIR)
	$(SH_DIR)/accelerator_build.sh

vivado: $(ACCEL_DIR) 
	sh/define_shell.sh
	mkdir -p binaries
	cp -r accelerator/meep_shell/binaries/* binaries/
	$(VIVADO_PATH) $(VIVADO_OPT) $(TCL_DIR)/init_ips.tcl
	$(VIVADO_PATH) $(VIVADO_OPT) $(TCL_DIR)/gen_top.tcl
	$(VIVADO_PATH) $(VIVADO_OPT) $(TCL_DIR)/gen_project.tcl
	
synthesis: vivado 
	$(VIVADO_PATH) $(VIVADO_OPT) $(TCL_DIR)/gen_synthesis.tcl -tclargs $(PROJECT_DIR)

implementation: $(SYNTH_DCP)
	$(VIVADO_PATH) $(VIVADO_OPT) $(TCL_DIR)/gen_implementation.tcl -tclargs $(PROJECT_DIR)
	
bitstream: $(IMPL_DCP)
	$(VIVADO_PATH) $(VIVADO_OPT) $(TCL_DIR)/gen_bitstream.tcl -tclargs $(PROJECT_DIR)
	
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


