g_project_dir=$(find . -name system.xpr -printf "%h\n")

vivado -mode batch -nolog -nojournal -notrace -source tcl/gen_bitstream.tcl -tclargs $g_project_dir
