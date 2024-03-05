ROOT_DIR     ?=  $(PWD)
TCL_DIR      =  $(ROOT_DIR)/tcl
SH_DIR	     =  $(ROOT_DIR)/sh
DEF_FILE     ?= $(ROOT_DIR)/ea_url.txt
LOAD_EA      ?=
EA_REPO      =  EMULATED_ACCELERATOR_REPO
EA_SHA       =  EMULATED_ACCELERATOR_SHA
EA_GIT_URL   = `grep -m 1 $(DEF_FILE) -e $(EA_REPO) | awk -F ' ' '$$2 {print $$2}' `
EA_GIT_SHA   = `grep -m 1 $(DEF_FILE) -e $(EA_SHA)  | awk -F ' ' '$$2 {print $$2}' `
EA_DIR       =  $(ROOT_DIR)/accelerator
EA_PARAM     ?=
OPTIONS      =
# EA_PARAM is related to the EA, to it can be parametrized from the Shell
# For MEEP/ACME, the options are: lagarto, ariane, pronoc, meep_dvino @10/11/2022
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
# taking default Xilinx install path if not propagated from environment var
VIVADO_VER    ?= 2021.2
XILINX_VIVADO ?= /opt/Xilinx/Vivado/$(VIVADO_VER)
LD_PRELOAD_PATH = LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1
VIVADO_XLNX   :=   $(XILINX_VIVADO)/bin/vivado
VIVADO_OPT   = -mode batch -nolog -nojournal -notrace -source
DCP_ON       ?=
QUICK_IMPL   ?=
U200_PART    = "xcu200-fsgd2104-2-e"
U280_PART    = "xcu280-fsvh2892-2L-e"
U55C_PART    = "xcu55c-fsvh2892-2L-e"
U200_BOARD   = "u200"
U280_BOARD   = "u280"
U55C_BOARD   = "u55c"
#SHELL := /bin/bash

# applying extra Xilinx licenses in case they are needed
export XILINXD_LICENSE_FILE := $(XILINXD_LICENSE_FILE):/opt/flexlm/license/Xilinx.lic

.PHONY: clean clean_project clean_accelerator clean_synthesis clean_implementation clean_ci_cd

#.DEFAULT_GOAL := initialize
all: binaries project synthesis implementation validate bitstream

u200: clean
	$(SH_DIR)/extract_part.sh $(U200_BOARD)

u280: clean
	@$(SH_DIR)/extract_part.sh $(U280_BOARD)

u55c: clean
	@($(SH_DIR)/extract_part.sh $(U55C_BOARD))

vcu128:
	@$(SH_DIR)/extract_part.sh $(VCU128_PART) $(VCU128_BOARD)


initialize: submodules clean clean_accelerator $(ACCEL_DIR)

project: clean_synthesis $(PROJECT_FILE)

binaries: $(BINARIES_DIR)

synthesis: $(SYNTH_DCP)

implementation: $(IMPL_DCP)

bitstream: $(BIT_FILE)

update_sha: $(ACCEL_DIR)
	# Update the ea_url file with the actual accelerator sha
	@$(SH_DIR)/update_sha.sh $(DEF_FILE)
	# Update the YAML file:
	#$(SH_DIR)/extract_url.sh

yaml: $(YAML_FILE)
	# Edit the YAML file to update the URLs
	@$(SH_DIR)/extract_url.sh

create_shell_structure:
	# Create a basic file structure in the accelerator folder to get shell compatibility
	@$(SH_DIR)/gen_struct_meep.sh $(ROOT_DIR)

$(ACCEL_DIR):
	$(SH_DIR)/load_module.sh $(LOAD_EA)
	@(EA_GIT_URL=$$(grep -m 1 $(DEF_FILE) -e $(EA_REPO) | awk -F ' ' '$$2 {print $$2}' ) ;\
	$(SH_DIR)/init_modules.sh $$EA_GIT_URL $(EA_GIT_SHA))


$(BINARIES_DIR):
	@$(SH_DIR)/accelerator_bin.sh
	@mkdir -p $(BINARIES_DIR)
	@cp -r accelerator/meep_shell/binaries/* $(BINARIES_DIR)

$(PROJECT_FILE): clean_ip $(ACCEL_DIR) rom_file
	@$(SH_DIR)/accelerator_build.sh $(EA_PARAM)
	$(SH_DIR)/init_vivado.sh $(VIVADO_XLNX) || (echo "The generation of MEEP Shell has failed $$?"; exit 1)

$(SYNTH_DCP):
	$(LD_PRELOAD_PATH) $(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/gen_synthesis.tcl -tclargs $(PROJECT_DIR)

$(IMPL_DCP): $(SYNTH_DCP)
	$(LD_PRELOAD_PATH) $(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/gen_implementation.tcl -tclargs $(ROOT_DIR) $(DCP_ON) $(QUICK_IMPL)

$(BIT_FILE): $(IMPL_DCP)
	$(LD_PRELOAD_PATH) $(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/gen_bitstream.tcl -tclargs $(ROOT_DIR)

#### Special calls for the CI/CD, where the change on the artifact timestamp disables the use of the "requirements"

ci_implementation:
	$(LD_PRELOAD_PATH) $(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/gen_implementation.tcl -tclargs $(ROOT_DIR) $(DCP_ON)

ci_bitstream:
	$(LD_PRELOAD_PATH) $(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/gen_bitstream.tcl -tclargs $(ROOT_DIR)

ci_report_route:
	$(LD_PRELOAD_PATH) $(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/report_route.tcl -tclargs $(ROOT_DIR)

#### Special script to adquire the best placement strategy #####

SmartPlace: $(SYNTH_DCP)
	$(LD_PRELOAD_PATH) $(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/SmartPlace.tcl -tclargs $(ROOT_DIR)

validate: $(REPORT_DIR)
	$(LD_PRELOAD_PATH) $(SH_DIR)/check_timing.sh

report_synth: $(SYNTH_DCP)
	$(LD_PRELOAD_PATH) $(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/report_synth.tcl -tclargs $(ROOT_DIR)

report_place: $(PLACE_DCP)
	echo "Make sure you have run the implementation process with the DCP_ON option"
	$(LD_PRELOAD_PATH) $(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/report_place.tcl -tclargs $(ROOT_DIR)

report_route: $(IMPL_DCP)
	$(LD_PRELOAD_PATH) $(VIVADO_XLNX) $(VIVADO_OPT) $(TCL_DIR)/report_route.tcl -tclargs $(ROOT_DIR)

#Help menu accelerator_build.sh
syntax_ea:
	${MAKE} -C $(ACCEL_DIR) syntax_ea
####

#Help menu accelerator_build.sh
help_ea:
	${MAKE} -C $(ACCEL_DIR) help_ea
####

# Compile benchmarks for FPGA
test_riscv_fpga:
	${MAKE} -C $(ACCEL_DIR) test_riscv_fpga

test_riscv_clean:
	${MAKE} -C $(ACCEL_DIR) test_riscv_clean

rom_file:
	@$(SH_DIR)/create_inforom.sh $(ROOT_DIR)
	@mv $(ROOT_DIR)/misc/initrom.mem $(ROOT_DIR)/ip/axi_brom/src/initrom.mem

####

submodules:
	@(git submodule update --init --recursive)

clean: clean_ip clean_project
	@rm -rf dcp reports src

clean_ip:
	@(make -C ip/100GbEthernet clean)
	@(make -C ip/10GbEthernet clean)
	@(make -C ip/pulp_uart clean)
	@(make -C ip/axi_brom clean)
	@(make -C ip/aurora-dma clean)
	@(make -C ip/aurora_raw clean)

clean_binaries:
	@rm -rf binaries

clean_project: clean_ip
	@rm -rf project

clean_accelerator:
	@rm -rf accelerator

clean_synthesis: clean_implementation
	@rm -rf dcp/synthesis.dcp

clean_implementation:
	@rm -rf dcp/implementation.dcp reports

clean_bitstream:
	@rm -rf bitstream

clean_all: clean clean_binaries clean_bitstream
	@rm -rf accelerator

