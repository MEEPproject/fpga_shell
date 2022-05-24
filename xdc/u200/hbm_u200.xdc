# No HBM on the u200, fake the pin to keep compatibility with HBM boards
set_property PACKAGE_PIN AR20             [get_ports hbm_cattrip]   		
set_property IOSTANDARD  LVCMOS18         [get_ports hbm_cattrip]   		
set_property PULLTYPE PULLDOWN            [get_ports hbm_cattrip]
