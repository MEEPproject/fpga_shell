##
## PCIe MGTY Interface
##
set_property PACKAGE_PIN BF41             [get_ports pcie_perstn]                          ;# Bank  67 VCCO - VCC1V8   - IO_L13P_T2L_N0_GC_QBC_67
set_property IOSTANDARD  LVCMOS18         [get_ports pcie_perstn]                          ;# Bank  67 VCCO - VCC1V8   - IO_L13P_T2L_N0_GC_QBC_67

set_property PACKAGE_PIN BC1              [get_ports {pci_express_x16_rxn[15]} ]                   ;# Bank 224 - MGTYRXN0_224
set_property PACKAGE_PIN BB3              [get_ports {pci_express_x16_rxn[14]} ]                   ;# Bank 224 - MGTYRXN1_224
set_property PACKAGE_PIN BA1              [get_ports {pci_express_x16_rxn[13]} ]                   ;# Bank 224 - MGTYRXN2_224
set_property PACKAGE_PIN BA5              [get_ports {pci_express_x16_rxn[12]} ]                   ;# Bank 224 - MGTYRXN3_224
set_property PACKAGE_PIN BC2              [get_ports {pci_express_x16_rxp[15]} ]                   ;# Bank 224 - MGTYRXP0_224
set_property PACKAGE_PIN BB4              [get_ports {pci_express_x16_rxp[14]} ]                   ;# Bank 224 - MGTYRXP1_224
set_property PACKAGE_PIN BA2              [get_ports {pci_express_x16_rxp[13]} ]                   ;# Bank 224 - MGTYRXP2_224
set_property PACKAGE_PIN BA6              [get_ports {pci_express_x16_rxp[12]} ]                   ;# Bank 224 - MGTYRXP3_224
set_property PACKAGE_PIN BC6              [get_ports {pci_express_x16_txn[15]} ]                   ;# Bank 224 - MGTYTXN0_224
set_property PACKAGE_PIN BC10             [get_ports {pci_express_x16_txn[14]} ]                   ;# Bank 224 - MGTYTXN1_224
set_property PACKAGE_PIN BB8              [get_ports {pci_express_x16_txn[13]} ]                   ;# Bank 224 - MGTYTXN2_224
set_property PACKAGE_PIN BA10             [get_ports {pci_express_x16_txn[12]} ]                   ;# Bank 224 - MGTYTXN3_224
set_property PACKAGE_PIN BC7              [get_ports {pci_express_x16_txp[15]} ]                   ;# Bank 224 - MGTYTXP0_224
set_property PACKAGE_PIN BC11             [get_ports {pci_express_x16_txp[14]} ]                   ;# Bank 224 - MGTYTXP1_224
set_property PACKAGE_PIN BB9              [get_ports {pci_express_x16_txp[13]} ]                   ;# Bank 224 - MGTYTXP2_224
set_property PACKAGE_PIN BA11             [get_ports {pci_express_x16_txp[12]} ]                   ;# Bank 224 - MGTYTXP3_224
set_property PACKAGE_PIN AR14             [get_ports pcie_refclk_clk_n ]                       ;# Bank 225 - MGTREFCLK0N_225
set_property PACKAGE_PIN AR15             [get_ports pcie_refclk_clk_p ]                       ;# Bank 225 - MGTREFCLK0P_225
# Set the reference clock
create_clock -period 10.000 -name  pcie_refclk [get_ports pcie_refclk_clk_p]
#set_property PACKAGE_PIN AP12             [get_ports "SYSCLK5_N"]                          ;# Bank 225 - MGTREFCLK1N_225
#set_property PACKAGE_PIN AP13             [get_ports "SYSCLK5_P"]                          ;# Bank 225 - MGTREFCLK1P_225
set_property PACKAGE_PIN AY3              [get_ports {pci_express_x16_rxn[11]} ]                   ;# Bank 225 - MGTYRXN0_225
set_property PACKAGE_PIN AW1              [get_ports {pci_express_x16_rxn[10]} ]                   ;# Bank 225 - MGTYRXN1_225
set_property PACKAGE_PIN AW5              [get_ports {pci_express_x16_rxn[9]} ]                    ;# Bank 225 - MGTYRXN2_225
set_property PACKAGE_PIN AV3              [get_ports {pci_express_x16_rxn[8]} ]                    ;# Bank 225 - MGTYRXN3_225
set_property PACKAGE_PIN AY4              [get_ports {pci_express_x16_rxp[11]} ]                   ;# Bank 225 - MGTYRXP0_225
set_property PACKAGE_PIN AW2              [get_ports {pci_express_x16_rxp[10]} ]                   ;# Bank 225 - MGTYRXP1_225
set_property PACKAGE_PIN AW6              [get_ports {pci_express_x16_rxp[9]} ]                    ;# Bank 225 - MGTYRXP2_225
set_property PACKAGE_PIN AV4              [get_ports {pci_express_x16_rxp[8]} ]                    ;# Bank 225 - MGTYRXP3_225
set_property PACKAGE_PIN AY8              [get_ports {pci_express_x16_txn[11]} ]                   ;# Bank 225 - MGTYTXN0_225
set_property PACKAGE_PIN AW10             [get_ports {pci_express_x16_txn[10]} ]                   ;# Bank 225 - MGTYTXN1_225
set_property PACKAGE_PIN AV8              [get_ports {pci_express_x16_txn[9]} ]                    ;# Bank 225 - MGTYTXN2_225
set_property PACKAGE_PIN AU6              [get_ports {pci_express_x16_txn[8]} ]                    ;# Bank 225 - MGTYTXN3_225
set_property PACKAGE_PIN AY9              [get_ports {pci_express_x16_txp[11]} ]                   ;# Bank 225 - MGTYTXP0_225
set_property PACKAGE_PIN AW11             [get_ports {pci_express_x16_txp[10]} ]                   ;# Bank 225 - MGTYTXP1_225
set_property PACKAGE_PIN AU7              [get_ports {pci_express_x16_txp[8]} ]                    ;# Bank 225 - MGTYTXP2_225
set_property PACKAGE_PIN AV9              [get_ports {pci_express_x16_txp[9]} ]                    ;# Bank 225 - MGTYTXP3_225
set_property PACKAGE_PIN AU1              [get_ports {pci_express_x16_rxn[7]} ]                    ;# Bank 226 - MGTYRXN0_226
set_property PACKAGE_PIN AT3              [get_ports {pci_express_x16_rxn[6]} ]                    ;# Bank 226 - MGTYRXN1_226
set_property PACKAGE_PIN AR1              [get_ports {pci_express_x16_rxn[5]} ]                    ;# Bank 226 - MGTYRXN2_226
set_property PACKAGE_PIN AP3              [get_ports {pci_express_x16_rxn[4]} ]                    ;# Bank 226 - MGTYRXN3_226
set_property PACKAGE_PIN AU2              [get_ports {pci_express_x16_rxp[7]} ]                    ;# Bank 226 - MGTYRXP0_226
set_property PACKAGE_PIN AT4              [get_ports {pci_express_x16_rxp[6]} ]                    ;# Bank 226 - MGTYRXP1_226
set_property PACKAGE_PIN AR2              [get_ports {pci_express_x16_rxp[5]} ]                    ;# Bank 226 - MGTYRXP2_226
set_property PACKAGE_PIN AP4              [get_ports {pci_express_x16_rxp[4]} ]                    ;# Bank 226 - MGTYRXP3_226
set_property PACKAGE_PIN AU10             [get_ports {pci_express_x16_txn[7]} ]                    ;# Bank 226 - MGTYTXN0_226
set_property PACKAGE_PIN AT8              [get_ports {pci_express_x16_txn[6]} ]                    ;# Bank 226 - MGTYTXN1_226
set_property PACKAGE_PIN AR6              [get_ports {pci_express_x16_txn[5]} ]                    ;# Bank 226 - MGTYTXN2_226
set_property PACKAGE_PIN AR10             [get_ports {pci_express_x16_txn[4]} ]                    ;# Bank 226 - MGTYTXN3_226
set_property PACKAGE_PIN AU11             [get_ports {pci_express_x16_txp[7]} ]                    ;# Bank 226 - MGTYTXP0_226
set_property PACKAGE_PIN AT9              [get_ports {pci_express_x16_txp[6]} ]                    ;# Bank 226 - MGTYTXP1_226
set_property PACKAGE_PIN AR7              [get_ports {pci_express_x16_txp[5]} ]                    ;# Bank 226 - MGTYTXP2_226
set_property PACKAGE_PIN AR11             [get_ports {pci_express_x16_txp[4]} ]                    ;# Bank 226 - MGTYTXP3_226
#set_property PACKAGE_PIN AL14             [get_ports {pcie_clk0_n} ]                       ;# Bank 227 - MGTREFCLK0N_227
#set_property PACKAGE_PIN AL15             [get_ports {pcie_clk0_n} ]                       ;# Bank 227 - MGTREFCLK0P_227
#set_property PACKAGE_PIN AK12             [get_ports {sys_clk2_n} ]                        ;# Bank 227 - MGTREFCLK1N_227
#set_property PACKAGE_PIN AK13             [get_ports {sys_clk2_n} ]                        ;# Bank 227 - MGTREFCLK1P_227
set_property PACKAGE_PIN AN1              [get_ports {pci_express_x16_rxn[3]} ]                    ;# Bank 227 - MGTYRXN0_227
set_property PACKAGE_PIN AN5              [get_ports {pci_express_x16_rxn[2]} ]                    ;# Bank 227 - MGTYRXN1_227
set_property PACKAGE_PIN AM3              [get_ports {pci_express_x16_rxn[1]} ]                    ;# Bank 227 - MGTYRXN2_227
set_property PACKAGE_PIN AL1              [get_ports {pci_express_x16_rxn[0]} ]                    ;# Bank 227 - MGTYRXN3_227
set_property PACKAGE_PIN AN2              [get_ports {pci_express_x16_rxp[3]} ]                    ;# Bank 227 - MGTYRXP0_227
set_property PACKAGE_PIN AN6              [get_ports {pci_express_x16_rxp[2]} ]                    ;# Bank 227 - MGTYRXP1_227
set_property PACKAGE_PIN AM4              [get_ports {pci_express_x16_rxp[1]} ]                    ;# Bank 227 - MGTYRXP2_227
set_property PACKAGE_PIN AL2              [get_ports {pci_express_x16_rxp[0]} ]                    ;# Bank 227 - MGTYRXP3_227
set_property PACKAGE_PIN AP8              [get_ports {pci_express_x16_txn[3]} ]                    ;# Bank 227 - MGTYTXN0_227
set_property PACKAGE_PIN AN10             [get_ports {pci_express_x16_txn[2]} ]                    ;# Bank 227 - MGTYTXN1_227
set_property PACKAGE_PIN AM8              [get_ports {pci_express_x16_txn[1]} ]                    ;# Bank 227 - MGTYTXN2_227
set_property PACKAGE_PIN AL10             [get_ports {pci_express_x16_txn[0]} ]                    ;# Bank 227 - MGTYTXN3_227
set_property PACKAGE_PIN AP9              [get_ports {pci_express_x16_txp[3]} ]                    ;# Bank 227 - MGTYTXP0_227
set_property PACKAGE_PIN AN11             [get_ports {pci_express_x16_txp[2]} ]                    ;# Bank 227 - MGTYTXP1_227
set_property PACKAGE_PIN AM9              [get_ports {pci_express_x16_txp[1]} ]                    ;# Bank 227 - MGTYTXP2_227
set_property PACKAGE_PIN AL11             [get_ports {pci_express_x16_txp[0]} ]  
