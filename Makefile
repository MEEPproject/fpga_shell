ROOT_DIR     =  $(PWD)
TCL_DIR      =  $(ROOT_DIR)/tcl
SH_DIR	     =  $(ROOT_DIR)/sh
DEF_FILE     =  $(ROOT_DIR)/ea_url.txt
EA_REPO      =  EMULATED_ACCELERATOR_REPO
EA_SHA       =  EMULATED_ACCELERATOR_SHA
EA_GIT_URL   = `grep -m 1 $(DEF_FILE) -e $(EA_REPO) | awk -F ' ' '$$2 {print $$2}' `
EA_GIT_SHA   = `grep -m 1 $(DEF_FILE) -e $(EA_SHA)  | awk -F ' ' '$$2 {print $$2}' `
EA_DIR       =  $(ROOT_DIR)/accelerator
DATE         =  `date +'%a %b %e %H:%M:$S %Z %Y'`
PROJECT_FILE =	$(ROOT_DIR)/project/system.xpr
ACCEL_DIR    =  $(ROOT_DIR)/accelerator
SYNTH_DCP    =  $(ROOT_DIR)/dcp/synthesis.dcp 
IMPL_DCP     =  $(ROOT_DIR)/dcp/implementation.dcp 
BIT_FILE     =  $(ROOT_DIR)/bitstream/system.bit
REPORT_DIR   =  $(ROOT_DIR)/reports
YAML_FILE    =  $(ROOT_DIR)/.gitlab-ci.yml
PROJECT_DIR  =  $(ROOT_DIR)/project
VIVADO_VER   ?= "2020.1"
VIVADO_PATH  := /opt/Xilinx/Vivado/$(VIVADO_VER)/bin/vivado
VIVADO_OPT   = -mode batch -nolog -nojournal -notrace -source
U280_PART    = "xcu280-fsvh2892-2L-e" 
U55C_PART    = "xcu55c-fsvh2892-2L-e"  
U280_BOARD   = "u280"
U55C_BOARD   = "u55c"

.PHONY: clean clean_shell clean_accelerator clean_synthesis clean_implementation clean_ci_cd

#.DEFAULT_GOAL := initialize
all: binaries vivado synthesis implementation bitstream validate

u280:
	$(SH_DIR)/extract_part.sh $(U280_PART) $(U280_BOARD)

u55c:
	$(SH_DIR)/extract_part.sh $(U55C_PART) $(U55C_BOARD)
	echo "Target Board: xcu55c. Make sure you call make using VIVADO_VER=2021.1"

initialize: clean $(ACCEL_DIR)

synthesis: $(SYNTH_DCP)

implementation: $(IMPL_DCP)

bitstream: $(BIT_FILE)

update_sha: $(ACCEL_DIR)
	# Update the ea_url file with the actual accelerator sha
	@$(SH_DIR)/update_sha.sh $(DEF_FILE)
	# Update the YAML file:
	$(SH_DIR)/extract_url.sh

yaml: $(YAML_FILE)
	# Edit the YAML file to update the URLs
	$(SH_DIR)/extract_url.sh

$(ACCEL_DIR): 
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
	
$(SYNTH_DCP):
	$(VIVADO_PATH) $(VIVADO_OPT) $(TCL_DIR)/gen_synthesis.tcl -tclargs $(PROJECT_DIR)

$(IMPL_DCP): $(SYNTH_DCP)
	$(VIVADO_PATH) $(VIVADO_OPT) $(TCL_DIR)/gen_implementation.tcl -tclargs $(ROOT_DIR)
	
$(BIT_FILE): $(IMPL_DCP)
	$(VIVADO_PATH) $(VIVADO_OPT) $(TCL_DIR)/gen_bitstream.tcl -tclargs $(ROOT_DIR)
	
validate: $(REPORT_DIR)
	$(SH_DIR)/check_reports.sh

clean: 
	rm -rf project dcp reports accelerator src binaries
	
clean_ci_cd:
	git checkout $(DEF_FILE)
	
clean_shell:
	rm -rf project
	
clean_accelerator:
	rm -rf accelerator

clean_synthesis:	
	rm -rf dcp/synthesis.dcp

clean_implementation:
	rm -rf dcp/implementation.dcp reports


