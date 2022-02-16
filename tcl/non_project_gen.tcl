cd e:/git_repo/fpga_shell

source tcl/gen_meep.tcl
read_verilog ./src/system_top.sv
set_property part xcu280-fsvh2892-2L-e [current_project]

read_bd project/meep_shell/meep_shell.bd
set_property synth_checkpoint_mode None [get_files meep_shell.bd]
upgrade_ip [get_ips]
generate_target -force all [get_files meep_shell.bd]
synth_desing -top system_top

