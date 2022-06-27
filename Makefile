ROOT_DIR     =  $(PWD)
TCL_DIR      =  $(ROOT_DIR)/tcl
SH_DIR	     =  $(ROOT_DIR)/sh
DEF_FILE     ?= $(ROOT_DIR)/ea_url.txt
LOAD_EA      ?= 
EA_REPO      =  EMULATED_ACCELERATOR_REPO
EA_SHA       =  EMULATED_ACCELERATOR_SHA
EA_GIT_URL   = `grep -m 1 $(DEF_FILE) -e $(EA_REPO) | awk -F ' ' '$$2 {print $$2}' `
EA_GIT_SHA   = `grep -m 1 $(DEF_FILE) -e $(EA_SHA)  | awk -F ' ' '$$2 {print $$2}' `
EA_DIR       =  $(ROOT_DIR)/accelerator
DATE         =  `date +'%a %b %e %H:%M:$S %Z %Y'`
PROJECT_FILE =	$(ROOT_DIR)/project/system.xpr
ACCEL_DIR    =  $(ROOT_DIR)/accelerator
SYNTH_DCP    =  $(ROOT_DIR)/dcp/synthesis.dcp 
PLACE_DCP    =  $(ROOT_DIR)/dcp/post_place.dcp 
IMPL_DCP     =  $(ROOT_DIR)/dcp/implementation.dcp 
BIT_FILE     =  $(ROOT_DIR)/bitstream/system.bit
REPORT_DIR   =  $(ROOT_DIR)/reports
YAML_FILE    =  $(ROOT_DIR)/.gitlab-ci.yml
PROJECT_DIR  =  $(ROOT_DIR)/project
BINARIES_DIR =  $(ROOT_DIR)/binaries
VIVADO_VER   ?= 2021.2
VIVADO_PATH  = /opt/Xilinx/Vivado/$(VIVADO_VER)/bin/
VIVADO_XLNX  ?= $(VIVADO_PATH)/vivado
VIVADO_OPT   = -mode batch -nolog -nojournal -notrace -source
DCP_ON       ?= 
U280_PART    = "xcu280-fsvh2892-2L-e" 
U55C_PART    = "xcu55c-fsvh2892-2L-e"  
U280_BOARD   = "u280"
U55C_BOARD   = "u55c"
#SHELL := /bin/bash

.PHONY: clean clean_project clean_accelerator clean_synthesis clean_implementation clean_ci_cd

#.DEFAULT_GOAL := initialize
all: initialize binaries project synthesis implementation validate bitstream

u280: clean
	$(SH_DIR)/extract_part.sh $(U280_BOARD) 

u55c: clean
	@($(SH_DIR)/extract_part.sh $(U55C_BOARD)) 
	@(echo "Target Board: xcu55c. Make sure you call make using VIVADO_VER=2021.2")

vcu128:	
	$(SH_DIR)/extract_part.sh $(VCU128_PART) $(VCU128_BOARD)


initialize: submodules clean $(ACCEL_DIR)

project: clean_synthesis $(PROJECT_FILE)

binaries: $(BINARIES_DIR)

synthesis: $(SYNTH_DCP)

implementation: $(IMPL_DCP)

bitstream: $(BIT_FILE)

bm_binaries:
	mkdir -p bin
	${MAKE} -C $(ACCEL_DIR)/sw/benchmarks/baremetal/apps clean
	${MAKE} -C $(ACCEL_DIR)/sw/benchmarks/baremetal/apps all
	${MAKE} -C $(ACCEL_DIR)/sw/benchmarks/baremetal/apps binaries

update_sha: $(ACCEL_DIR)
	# Update the ea_url file with the actual accelerator sha
	@$(SH_DIR)/update_sha.sh $(DEF_FILE)
	# Update the YAML file:
	#$(SH_DIR)/extract_url.sh

yaml: $(YAML_FILE)
	# Edit the YAML file to update the URLs
	$(SH_DIR)/extract_url.sh

$(ACCEL_DIR):
	$(SH_DIR)/load_module.sh $(LOAD_EA)
	@(EA_GIT_URL=$$(grep -m 1 $(DEF_FILE) -e $(EA_REPO) | awk -F ' ' '$$2 {print $$2}' ) ;\
	$(SH_DIR)/init_modules.sh $$EA_GIT_URL $(EA_GIT_SHA))


$(BINARIES_DIR):
	$(SH_DIR)/accelerator_bin.sh
	mkdir -p $(BINARIES_DIR)
	cp -r accelerator/meep_shell/binaries/* $(BINARIES_DIR)

$(PROJECT_FILE): clean_ip $(ACCEL_DIR)
	$(SH_DIR)/accelerator_build.sh ;\
	$(SH_DIR)/init_vivado.sh $(VIVADO_XLNX)
	
$(SYNTH_DCP):
	$(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/gen_synthesis.tcl -tclargs $(PROJECT_DIR)

$(IMPL_DCP): $(SYNTH_DCP)
	$(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/gen_implementation.tcl -tclargs $(ROOT_DIR) $(DCP_ON)
	
$(BIT_FILE): $(IMPL_DCP)
	$(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/gen_bitstream.tcl -tclargs $(ROOT_DIR)
	
#### Special calls for the CI/CD, where the change on the artifact timestamp disables the use of the "requirements"

ci_implementation: 
	$(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/gen_implementation.tcl -tclargs $(ROOT_DIR) $(DCP_ON)
	
ci_bitstream: 
	$(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/gen_bitstream.tcl -tclargs $(ROOT_DIR)
	

#### Special script to adquire the best placement strategy #####

SmartPlace: $(SYNTH_DCP)
	$(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/SmartPlace.tcl -tclargs $(ROOT_DIR)
	
validate: $(REPORT_DIR)
	$(SH_DIR)/check_timing.sh

report_synth: $(SYNTH_DCP)
	$(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/report_synth.tcl -tclargs $(ROOT_DIR)

report_place: $(PLACE_DCP)
	echo "Make sure you have run the implementation process with the DCP_ON option"
	$(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/report_place.tcl -tclargs $(ROOT_DIR)

report_route: $(IMPL_DCP)
	$(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/report_route.tcl -tclargs $(ROOT_DIR)

submodules:	
	@(git submodule update --init --recursive)

clean: clean_ip clean_project
	rm -rf dcp reports src 	

clean_ip: 
	@(cd ip/100GbEthernet; make clean)
	@(cd ip/aurora_raw; make clean)
	@(cd ip/10GbEthernet; make clean)

clean_binaries:
	rm -rf binaries
	
clean_project: clean_ip 
	rm -rf project
	
clean_accelerator:
	rm -rf accelerator

clean_synthesis:	
	rm -rf dcp/synthesis.dcp

clean_implementation:
	rm -rf dcp/implementation.dcp reports

clean_bitstream:
	rm -rf bitstream

clean_all: clean clean_binaries clean_bitstream
	rm -rf accelerator

