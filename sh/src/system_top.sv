module system_top
   (
    // Main input clock
    input         sysclk0_clk_n  ,
    input         sysclk0_clk_p  ,
    // Secondary clock
    input         sysclk1_clk_n  ,
    input         sysclk1_clk_p  , 
    // Secondary clock
    //input         sysclk3_clk_n  ,
    //input         sysclk3_clk_p  ,	
	// system reset - CPU_RESET L30
    input         resetn  ,
    // PCI express
	input         pcie_refclk_clk_n    ,
    input         pcie_refclk_clk_p    ,
    input         pcie_perstn          ,		
    input  [15:0] pci_express_x16_rxn  ,
    input  [15:0] pci_express_x16_rxp  ,
    output [15:0] pci_express_x16_txn  ,
    output [15:0] pci_express_x16_txp  ,
    // DDR4
    output        ddr4_sdram_c0_act_n   ,
    output [16:0] ddr4_sdram_c0_adr     ,
    output [1:0]  ddr4_sdram_c0_ba      ,
    output [1:0]  ddr4_sdram_c0_bg      ,
    output        ddr4_sdram_c0_ck_c    ,
    output        ddr4_sdram_c0_ck_t    ,
    output        ddr4_sdram_c0_cke     ,
    output        ddr4_sdram_c0_cs_n    ,
    inout  [71:0] ddr4_sdram_c0_dq      ,
    inout  [17:0] ddr4_sdram_c0_dqs_c   ,
    inout  [17:0] ddr4_sdram_c0_dqs_t   ,
    output        ddr4_sdram_c0_odt     ,
    output        ddr4_sdram_c0_par     ,
    output        ddr4_sdram_c0_reset_n ,
    // UART
    input         rs232_rxd  ,
    output        rs232_txd  ,
    output        hbm_cattrip 
   ); 
 
    wire clk_asic    ;  	    	  
    wire rstn_asic    ;  	    	  
    wire uart_rxd    ;  	    	  
    wire uart_txd    ;  	    	  
    wire tdi    ;  	    	  
    wire tdo    ;  	    	  
    wire tms    ;  	    	  
    wire tck    ;  	    	  
    wire mem_nasti_awready    ;  	    	  
    wire mem_nasti_awvalid    ;  	    	  
    wire [7:0] mem_nasti_awid    ;  	    	  
    wire mem_nasti_awuser    ;  	    	  
    wire [31:0] mem_nasti_awaddr    ;  	    	  
    wire [2:0] mem_nasti_awprot    ;  	    	  
    wire [3:0] mem_nasti_awqos    ;  	    	  
    wire [3:0] mem_nasti_awregion    ;  	    	  
    wire [7:0] mem_nasti_awlen    ;  	    	  
    wire [2:0] mem_nasti_awsize    ;  	    	  
    wire [1:0] mem_nasti_awburst    ;  	    	  
    wire mem_nasti_awlock    ;  	    	  
    wire [3:0] mem_nasti_awcache    ;  	    	  
    wire mem_nasti_wready    ;  	    	  
    wire mem_nasti_wvalid    ;  	    	  
    wire [127:0] mem_nasti_wdata    ;  	    	  
    wire mem_nasti_wuser    ;  	    	  
    wire [15:0] mem_nasti_wstrb    ;  	    	  
    wire mem_nasti_wlast    ;  	    	  
    wire mem_nasti_bready    ;  	    	  
    wire mem_nasti_bvalid    ;  	    	  
    wire [7:0] mem_nasti_bid    ;  	    	  
    wire mem_nasti_buser    ;  	    	  
    wire [1:0] mem_nasti_bresp    ;  	    	  
    wire mem_nasti_arready    ;  	    	  
    wire mem_nasti_arvalid    ;  	    	  
    wire [7:0] mem_nasti_arid    ;  	    	  
    wire mem_nasti_aruser    ;  	    	  
    wire [31:0] mem_nasti_araddr    ;  	    	  
    wire [2:0] mem_nasti_arprot    ;  	    	  
    wire [3:0] mem_nasti_arqos    ;  	    	  
    wire [3:0] mem_nasti_arregion    ;  	    	  
    wire [7:0] mem_nasti_arlen    ;  	    	  
    wire [2:0] mem_nasti_arsize    ;  	    	  
    wire [1:0] mem_nasti_arburst    ;  	    	  
    wire mem_nasti_arlock    ;  	    	  
    wire [3:0] mem_nasti_arcache    ;  	    	  
    wire mem_nasti_rready    ;  	    	  
    wire mem_nasti_rvalid    ;  	    	  
    wire [7:0] mem_nasti_rid    ;  	    	  
    wire mem_nasti_ruser    ;  	    	  
    wire [1:0] mem_nasti_rresp    ;  	    	  
    wire [127:0] mem_nasti_rdata    ;  	    	  
    wire mem_nasti_rlast    ;  	    	  

 meep_shell meep_shell_inst
   (
    .sysclk0_clk_n     (sysclk0_clk_n)    ,
    .sysclk0_clk_p     (sysclk0_clk_p)    ,
    .sysclk1_clk_n     (sysclk1_clk_n)    ,
    .sysclk1_clk_p     (sysclk1_clk_p)    ,
    .resetn     (resetn)    ,
    .pcie_refclk_clk_n     (pcie_refclk_clk_n)    ,
    .pcie_refclk_clk_p     (pcie_refclk_clk_p)    ,
    .pcie_perstn     (pcie_perstn)    ,
    .pci_express_x16_rxn     (pci_express_x16_rxn)    ,
    .pci_express_x16_rxp     (pci_express_x16_rxp)    ,
    .pci_express_x16_txn     (pci_express_x16_txn)    ,
    .pci_express_x16_txp     (pci_express_x16_txp)    ,
    .ddr4_sdram_c0_act_n     (ddr4_sdram_c0_act_n)    ,
    .ddr4_sdram_c0_adr     (ddr4_sdram_c0_adr)    ,
    .ddr4_sdram_c0_ba     (ddr4_sdram_c0_ba)    ,
    .ddr4_sdram_c0_bg     (ddr4_sdram_c0_bg)    ,
    .ddr4_sdram_c0_ck_c     (ddr4_sdram_c0_ck_c)    ,
    .ddr4_sdram_c0_ck_t     (ddr4_sdram_c0_ck_t)    ,
    .ddr4_sdram_c0_cke     (ddr4_sdram_c0_cke)    ,
    .ddr4_sdram_c0_cs_n     (ddr4_sdram_c0_cs_n)    ,
    .ddr4_sdram_c0_dq     (ddr4_sdram_c0_dq)    ,
    .ddr4_sdram_c0_dqs_c     (ddr4_sdram_c0_dqs_c)    ,
    .ddr4_sdram_c0_dqs_t     (ddr4_sdram_c0_dqs_t)    ,
    .ddr4_sdram_c0_odt     (ddr4_sdram_c0_odt)    ,
    .ddr4_sdram_c0_par     (ddr4_sdram_c0_par)    ,
    .ddr4_sdram_c0_reset_n     (ddr4_sdram_c0_reset_n)    ,
    .rs232_rxd     (rs232_rxd)    ,
    .rs232_txd     (rs232_txd)    ,
    .mem_nasti_awready       (mem_nasti_awready   )    , 
    .mem_nasti_awvalid       (mem_nasti_awvalid   )    , 
    .mem_nasti_awid          (mem_nasti_awid      )    , 
    .mem_nasti_awuser        (mem_nasti_awuser    )    , 
    .mem_nasti_awaddr        (mem_nasti_awaddr    )    , 
    .mem_nasti_awprot        (mem_nasti_awprot    )    , 
    .mem_nasti_awqos         (mem_nasti_awqos     )    , 
    .mem_nasti_awregion      (mem_nasti_awregion  )    , 
    .mem_nasti_awlen         (mem_nasti_awlen     )    , 
    .mem_nasti_awsize        (mem_nasti_awsize    )    , 
    .mem_nasti_awburst       (mem_nasti_awburst   )    , 
    .mem_nasti_awlock        (mem_nasti_awlock    )    , 
    .mem_nasti_awcache       (mem_nasti_awcache   )    , 
    .mem_nasti_wready        (mem_nasti_wready    )    , 
    .mem_nasti_wvalid        (mem_nasti_wvalid    )    , 
    .mem_nasti_wdata         (mem_nasti_wdata     )    , 
    .mem_nasti_wuser         (mem_nasti_wuser     )    , 
    .mem_nasti_wstrb         (mem_nasti_wstrb     )    , 
    .mem_nasti_wlast         (mem_nasti_wlast     )    , 
    .mem_nasti_bready        (mem_nasti_bready    )    , 
    .mem_nasti_bvalid        (mem_nasti_bvalid    )    , 
    .mem_nasti_bid           (mem_nasti_bid       )    , 
    .mem_nasti_buser         (mem_nasti_buser     )    , 
    .mem_nasti_bresp         (mem_nasti_bresp     )    , 
    .mem_nasti_arready       (mem_nasti_arready   )    , 
    .mem_nasti_arvalid       (mem_nasti_arvalid   )    , 
    .mem_nasti_arid          (mem_nasti_arid      )    , 
    .mem_nasti_aruser        (mem_nasti_aruser    )    , 
    .mem_nasti_araddr        (mem_nasti_araddr    )    , 
    .mem_nasti_arprot        (mem_nasti_arprot    )    , 
    .mem_nasti_arqos         (mem_nasti_arqos     )    , 
    .mem_nasti_arregion      (mem_nasti_arregion  )    , 
    .mem_nasti_arlen         (mem_nasti_arlen     )    , 
    .mem_nasti_arsize        (mem_nasti_arsize    )    , 
    .mem_nasti_arburst       (mem_nasti_arburst   )    , 
    .mem_nasti_arlock        (mem_nasti_arlock    )    , 
    .mem_nasti_arcache       (mem_nasti_arcache   )    , 
    .mem_nasti_rready        (mem_nasti_rready    )    , 
    .mem_nasti_rvalid        (mem_nasti_rvalid    )    , 
    .mem_nasti_rid           (mem_nasti_rid       )    , 
    .mem_nasti_ruser         (mem_nasti_ruser     )    , 
    .mem_nasti_rresp         (mem_nasti_rresp     )    , 
    .mem_nasti_rdata         (mem_nasti_rdata     )    , 
    .mem_nasti_rlast         (mem_nasti_rlast     )    , 
    .clk_asic        (clk_asic)    , 
    .rstn_asic        (rstn_asic)    , 
    .uart_rxd    (uart_rxd)    , 
    .uart_txd      (uart_txd  )    , 
    .hbm_cattrip             (hbm_cattrip)
);

dvino_meep_wrapper dvino_meep_wrapper_inst ( 
     .clk_asic     (clk_asic)    
,    .rstn_asic     (rstn_asic)    
,    .uart_rxd     (uart_rxd)    
,    .uart_txd     (uart_txd)    
,    .tdi     (tdi)    
,    .tdo     (tdo)    
,    .tms     (tms)    
,    .tck     (tck)    
,    .mem_nasti_awready     (mem_nasti_awready)    
,    .mem_nasti_awvalid     (mem_nasti_awvalid)    
,    .mem_nasti_awid     (mem_nasti_awid)    
,    .mem_nasti_awuser     (mem_nasti_awuser)    
,    .mem_nasti_awaddr     (mem_nasti_awaddr)    
,    .mem_nasti_awprot     (mem_nasti_awprot)    
,    .mem_nasti_awqos     (mem_nasti_awqos)    
,    .mem_nasti_awregion     (mem_nasti_awregion)    
,    .mem_nasti_awlen     (mem_nasti_awlen)    
,    .mem_nasti_awsize     (mem_nasti_awsize)    
,    .mem_nasti_awburst     (mem_nasti_awburst)    
,    .mem_nasti_awlock     (mem_nasti_awlock)    
,    .mem_nasti_awcache     (mem_nasti_awcache)    
,    .mem_nasti_wready     (mem_nasti_wready)    
,    .mem_nasti_wvalid     (mem_nasti_wvalid)    
,    .mem_nasti_wdata     (mem_nasti_wdata)    
,    .mem_nasti_wuser     (mem_nasti_wuser)    
,    .mem_nasti_wstrb     (mem_nasti_wstrb)    
,    .mem_nasti_wlast     (mem_nasti_wlast)    
,    .mem_nasti_bready     (mem_nasti_bready)    
,    .mem_nasti_bvalid     (mem_nasti_bvalid)    
,    .mem_nasti_bid     (mem_nasti_bid)    
,    .mem_nasti_buser     (mem_nasti_buser)    
,    .mem_nasti_bresp     (mem_nasti_bresp)    
,    .mem_nasti_arready     (mem_nasti_arready)    
,    .mem_nasti_arvalid     (mem_nasti_arvalid)    
,    .mem_nasti_arid     (mem_nasti_arid)    
,    .mem_nasti_aruser     (mem_nasti_aruser)    
,    .mem_nasti_araddr     (mem_nasti_araddr)    
,    .mem_nasti_arprot     (mem_nasti_arprot)    
,    .mem_nasti_arqos     (mem_nasti_arqos)    
,    .mem_nasti_arregion     (mem_nasti_arregion)    
,    .mem_nasti_arlen     (mem_nasti_arlen)    
,    .mem_nasti_arsize     (mem_nasti_arsize)    
,    .mem_nasti_arburst     (mem_nasti_arburst)    
,    .mem_nasti_arlock     (mem_nasti_arlock)    
,    .mem_nasti_arcache     (mem_nasti_arcache)    
,    .mem_nasti_rready     (mem_nasti_rready)    
,    .mem_nasti_rvalid     (mem_nasti_rvalid)    
,    .mem_nasti_rid     (mem_nasti_rid)    
,    .mem_nasti_ruser     (mem_nasti_ruser)    
,    .mem_nasti_rresp     (mem_nasti_rresp)    
,    .mem_nasti_rdata     (mem_nasti_rdata)    
,    .mem_nasti_rlast     (mem_nasti_rlast)    
    ) ;

endmodule
