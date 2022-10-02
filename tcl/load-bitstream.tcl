if { $argc != 2 } {
    puts "Usage: $argv0 <bitstream> <fpga-iSerial>"
    exit
}
set bitFile [lindex $argv 0]
set fpgajtag [lindex $argv 1]
set A "A"
set fpgajtagA $fpgajtag$A
puts "fpgajtagA is $fpgajtagA"
set target "localhost:3121/xilinx_tcf/Xilinx/$fpgajtagA"

puts "target is $target"


open_hw_manager
connect_hw_server -url localhost:3121
# get_hw_targets
current_hw_target $target
open_hw_target
set dev [lindex [get_hw_devices] 0]
current_hw_device $dev
puts "programming $bitFile into $dev..."
set_property PROGRAM.FILE $bitFile $dev
#set_property PROBES.FILE {./project_1.runs/impl_1/design_1_wrapper.ltx} [lindex [get_hw_devices] 0]
program_hw_devices $dev
exit

