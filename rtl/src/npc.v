//`include "/home/bourne/ysyx-workbench/npc/vsrc/alu.v"


module npc(                                                                                                                                 
    input        clock             ,
    input        reset           
);
	// core_top 输出信号
    wire [ 3: 0] core_top_arid_o   ;
	wire [31: 0] core_top_araddr_o ;
    wire [ 7: 0] core_top_arlen_o  ;
    wire [ 2: 0] core_top_arsize_o ;
    wire [ 1: 0] core_top_arburst_o;
	wire         core_top_arvalid_o;
	wire         core_top_rready_o ;
    wire [ 3: 0] core_top_awid_o   ;
	wire [31: 0] core_top_awaddr_o ;
    wire [ 7: 0] core_top_awlen_o  ;
    wire [ 2: 0] core_top_awsize_o ;
    wire [ 1: 0] core_top_awburst_o;
	wire         core_top_awvalid_o;
    wire [ 3: 0] core_top_wid_o    ;
	wire [31: 0] core_top_wdata_o  ;
	wire [ 3: 0] core_top_wstrb_o  ;
    wire         core_top_wlast_o  ;
	wire         core_top_wvalid_o ;
	wire         core_top_bready_o ;
    // Xbar 输出信号
    wire         xbar_arready_o    ;
    wire [ 3: 0] xbar_rid_o        ;
    wire [31: 0] xbar_rdata_o      ;
    wire [ 1: 0] xbar_rresp_o      ;
    wire         xbar_rlast_o      ;
    wire         xbar_rvalid_o     ;
    wire         xbar_awready_o    ;
    wire         xbar_wready_o     ;
    wire [ 3: 0] xbar_bid_o        ;
    wire [ 1: 0] xbar_bresp_o      ;
    wire         xbar_bvalid_o     ;

    wire [ 3: 0] xbar_s0_arid_o    ;
    wire [31: 0] xbar_s0_araddr_o  ;
    wire [ 7: 0] xbar_s0_arlen_o   ;
    wire [ 2: 0] xbar_s0_arsize_o  ;
    wire [ 1: 0] xbar_s0_arburst_o ;
    wire         xbar_s0_arvalid_o ;
    wire         xbar_s0_rready_o  ;
    wire [ 3: 0] xbar_s0_awid_o    ;
    wire [31: 0] xbar_s0_awaddr_o  ;
    wire [ 7: 0] xbar_s0_awlen_o   ;
    wire [ 2: 0] xbar_s0_awsize_o  ;
    wire [ 1: 0] xbar_s0_awburst_o ;
    wire         xbar_s0_awvalid_o ;
    wire [ 3: 0] xbar_s0_wid_o     ;
    wire [31: 0] xbar_s0_wdata_o   ;
    wire [ 3: 0] xbar_s0_wstrb_o   ;
    wire         xbar_s0_wlast_o   ;
    wire         xbar_s0_wvalid_o  ;
    wire         xbar_s0_bready_o  ;

    wire [ 3: 0] xbar_s1_arid_o    ;
    wire [31: 0] xbar_s1_araddr_o  ;
    wire [ 7: 0] xbar_s1_arlen_o   ;
    wire [ 2: 0] xbar_s1_arsize_o  ;
    wire [ 1: 0] xbar_s1_arburst_o ;
    wire         xbar_s1_arvalid_o ;
    wire         xbar_s1_rready_o  ;
    wire [ 3: 0] xbar_s1_awid_o    ;
    wire [31: 0] xbar_s1_awaddr_o  ;
    wire [ 7: 0] xbar_s1_awlen_o   ;
    wire [ 2: 0] xbar_s1_awsize_o  ;
    wire [ 1: 0] xbar_s1_awburst_o ;
    wire         xbar_s1_awvalid_o ;
    wire [ 3: 0] xbar_s1_wid_o     ;
    wire [31: 0] xbar_s1_wdata_o   ;
    wire [ 3: 0] xbar_s1_wstrb_o   ;
    wire         xbar_s1_wlast_o   ;
    wire         xbar_s1_wvalid_o  ;
    wire         xbar_s1_bready_o  ;

    wire [ 3: 0] xbar_s2_arid_o    ;
    wire [31: 0] xbar_s2_araddr_o  ;
    wire [ 7: 0] xbar_s2_arlen_o   ;
    wire [ 2: 0] xbar_s2_arsize_o  ;
    wire [ 1: 0] xbar_s2_arburst_o ;
    wire         xbar_s2_arvalid_o ;
    wire         xbar_s2_rready_o  ;
    wire [ 3: 0] xbar_s2_awid_o    ;
    wire [31: 0] xbar_s2_awaddr_o  ;
    wire [ 7: 0] xbar_s2_awlen_o   ;
    wire [ 2: 0] xbar_s2_awsize_o  ;
    wire [ 1: 0] xbar_s2_awburst_o ;
    wire         xbar_s2_awvalid_o ;
    wire [ 3: 0] xbar_s2_wid_o     ;
    wire [31: 0] xbar_s2_wdata_o   ;
    wire [ 3: 0] xbar_s2_wstrb_o   ;
    wire         xbar_s2_wlast_o   ;
    wire         xbar_s2_wvalid_o  ;
    wire         xbar_s2_bready_o  ;

	// mem 输出信号
    wire         mem_arready_o   ;
    wire [ 3: 0] mem_rid_o       ;
    wire [31: 0] mem_rdata_o     ;
    wire [ 1: 0] mem_rresp_o     ;
    wire         mem_rlast_o     ;
    wire         mem_rvalid_o    ;
    wire         mem_awready_o   ;
    wire         mem_wready_o    ;
    wire [ 3: 0] mem_bid_o       ;
    wire [ 1: 0] mem_bresp_o     ;
    wire         mem_bvalid_o    ;

    // UART 输出信号
    wire         uart_arready_o    ;
    wire [ 3: 0] uart_rid_o        ;
    wire [31: 0] uart_rdata_o      ;
    wire [ 1: 0] uart_rresp_o      ;
    wire         uart_rlast_o      ;
    wire         uart_rvalid_o     ;
    wire         uart_awready_o    ;
    wire         uart_wready_o     ;
    wire [ 3: 0] uart_bid_o        ;
    wire [ 1: 0] uart_bresp_o      ;
    wire         uart_bvalid_o     ;
    // CLINT 输出信号
    wire         clint_arready_o   ;
    wire [ 3: 0] clint_rid_o       ;
    wire [31: 0] clint_rdata_o     ;
    wire [ 1: 0] clint_rresp_o     ;
    wire         clint_rlast_o     ;
    wire         clint_rvalid_o    ;
    wire         clint_awready_o   ;
    wire         clint_wready_o    ;
    wire [ 3: 0] clint_bid_o       ;
    wire [ 1: 0] clint_bresp_o     ;
    wire         clint_bvalid_o    ;


	core_top  core_top_inst (
        .clk_i       (clock             ),
        .rst_n_i     (~reset            ),
        .arid_o      (core_top_arid_o   ),
        .araddr_o    (core_top_araddr_o ),
        .arlen_o     (core_top_arlen_o  ),
        .arsize_o    (core_top_arsize_o ),
        .arburst_o   (core_top_arburst_o),
        .arvalid_o   (core_top_arvalid_o),
        .arready_i   (xbar_arready_o    ),
        .rid_i       (xbar_rid_o        ),
        .rdata_i     (xbar_rdata_o      ),
        .rresp_i     (xbar_rresp_o      ),
        .rlast_i     (xbar_rlast_o      ),
        .rvalid_i    (xbar_rvalid_o     ),
        .rready_o    (core_top_rready_o ),
        .awid_o      (core_top_awid_o   ),
        .awaddr_o    (core_top_awaddr_o ),
        .awlen_o     (core_top_awlen_o  ),
        .awsize_o    (core_top_awsize_o ),
        .awburst_o   (core_top_awburst_o),
        .awvalid_o   (core_top_awvalid_o),
        .awready_i   (xbar_awready_o    ),
        .wid_o       (core_top_wid_o    ),
        .wdata_o     (core_top_wdata_o  ),
        .wstrb_o     (core_top_wstrb_o  ),
        .wlast_o     (core_top_wlast_o  ),
        .wvalid_o    (core_top_wvalid_o ),
        .wready_i    (xbar_wready_o     ),
        .bid_i       (xbar_bid_o        ),
        .bresp_i     (xbar_bresp_o      ),
        .bvalid_i    (xbar_bvalid_o     ),
        .bready_o    (core_top_bready_o )
    );

    Xbar_NSoC  Xbar_NSoC_inst (
        .clk_i       (clock             ),
        .rst_n_i     (~reset            ),
        .arid_i      (core_top_arid_o   ),
        .araddr_i    (core_top_araddr_o ),
        .arlen_i     (core_top_arlen_o  ),
        .arsize_i    (core_top_arsize_o ),
        .arburst_i   (core_top_arburst_o),
        .arvalid_i   (core_top_arvalid_o),
        .arready_o   (xbar_arready_o    ),
        .rid_o       (xbar_rid_o        ),
        .rdata_o     (xbar_rdata_o      ),
        .rresp_o     (xbar_rresp_o      ),
        .rlast_o     (xbar_rlast_o      ),
        .rvalid_o    (xbar_rvalid_o     ),
        .rready_i    (core_top_rready_o ),
        .awid_i      (core_top_awid_o   ),
        .awaddr_i    (core_top_awaddr_o ),
        .awlen_i     (core_top_awlen_o  ),
        .awsize_i    (core_top_awsize_o ),
        .awburst_i   (core_top_awburst_o),
        .awvalid_i   (core_top_awvalid_o),
        .awready_o   (xbar_awready_o    ),
        .wid_i       (core_top_wid_o    ),
        .wdata_i     (core_top_wdata_o  ),
        .wstrb_i     (core_top_wstrb_o  ),
        .wlast_i     (core_top_wlast_o  ),
        .wvalid_i    (core_top_wvalid_o ),
        .wready_o    (xbar_wready_o     ),
        .bid_o       (xbar_bid_o        ),
        .bresp_o     (xbar_bresp_o      ),
        .bvalid_o    (xbar_bvalid_o     ),
        .bready_i    (core_top_bready_o ),

        .s0_arid_o   (xbar_s0_arid_o    ),
        .s0_araddr_o (xbar_s0_araddr_o  ),
        .s0_arlen_o  (xbar_s0_arlen_o   ),
        .s0_arsize_o (xbar_s0_arsize_o  ),
        .s0_arburst_o(xbar_s0_arburst_o ),
        .s0_arvalid_o(xbar_s0_arvalid_o ),
        .s0_arready_i(clint_arready_o   ),
        .s0_rid_i    (clint_rid_o       ),
        .s0_rdata_i  (clint_rdata_o     ),
        .s0_rresp_i  (clint_rresp_o     ),
        .s0_rlast_i  (clint_rlast_o     ),
        .s0_rvalid_i (clint_rvalid_o    ),
        .s0_rready_o (xbar_s0_rready_o  ),
        .s0_awid_o   (xbar_s0_awid_o    ),
        .s0_awaddr_o (xbar_s0_awaddr_o  ),
        .s0_awlen_o  (xbar_s0_awlen_o   ),
        .s0_awsize_o (xbar_s0_awsize_o  ),
        .s0_awburst_o(xbar_s0_awburst_o ),
        .s0_awvalid_o(xbar_s0_awvalid_o ),
        .s0_awready_i(clint_awready_o   ),
        .s0_wid_o    (xbar_s0_wid_o     ),
        .s0_wdata_o  (xbar_s0_wdata_o   ),
        .s0_wstrb_o  (xbar_s0_wstrb_o   ),
        .s0_wlast_o  (xbar_s0_wlast_o   ),
        .s0_wvalid_o (xbar_s0_wvalid_o  ),
        .s0_wready_i (clint_wready_o    ),
        .s0_bid_i    (clint_bid_o       ),
        .s0_bresp_i  (clint_bresp_o     ),
        .s0_bvalid_i (clint_bvalid_o    ),
        .s0_bready_o (xbar_s0_bready_o  ),

        .s1_arid_o   (xbar_s1_arid_o    ),
        .s1_araddr_o (xbar_s1_araddr_o  ),
        .s1_arlen_o  (xbar_s1_arlen_o   ),
        .s1_arsize_o (xbar_s1_arsize_o  ),
        .s1_arburst_o(xbar_s1_arburst_o ),
        .s1_arvalid_o(xbar_s1_arvalid_o ),
        .s1_arready_i(mem_arready_o     ),
        .s1_rid_i    (mem_rid_o         ),
        .s1_rdata_i  (mem_rdata_o       ),
        .s1_rresp_i  (mem_rresp_o       ),
        .s1_rlast_i  (mem_rlast_o       ),
        .s1_rvalid_i (mem_rvalid_o      ),
        .s1_rready_o (xbar_s1_rready_o  ),
        .s1_awid_o   (xbar_s1_awid_o    ),
        .s1_awaddr_o (xbar_s1_awaddr_o  ),
        .s1_awlen_o  (xbar_s1_awlen_o   ),
        .s1_awsize_o (xbar_s1_awsize_o  ),
        .s1_awburst_o(xbar_s1_awburst_o ),
        .s1_awvalid_o(xbar_s1_awvalid_o ),
        .s1_awready_i(mem_awready_o     ),
        .s1_wid_o    (xbar_s1_wid_o     ),
        .s1_wdata_o  (xbar_s1_wdata_o   ),
        .s1_wstrb_o  (xbar_s1_wstrb_o   ),
        .s1_wlast_o  (xbar_s1_wlast_o   ),
        .s1_wvalid_o (xbar_s1_wvalid_o  ),
        .s1_wready_i (mem_wready_o      ),
        .s1_bid_i    (mem_bid_o         ),
        .s1_bresp_i  (mem_bresp_o       ),
        .s1_bvalid_i (mem_bvalid_o      ),
        .s1_bready_o (xbar_s1_bready_o  ),

        .s2_arid_o   (xbar_s2_arid_o    ),
        .s2_araddr_o (xbar_s2_araddr_o  ),
        .s2_arlen_o  (xbar_s2_arlen_o   ),
        .s2_arsize_o (xbar_s2_arsize_o  ),
        .s2_arburst_o(xbar_s2_arburst_o ),
        .s2_arvalid_o(xbar_s2_arvalid_o ),
        .s2_arready_i(uart_arready_o    ),
        .s2_rid_i    (uart_rid_o        ),
        .s2_rdata_i  (uart_rdata_o      ),
        .s2_rresp_i  (uart_rresp_o      ),
        .s2_rlast_i  (uart_rlast_o      ),
        .s2_rvalid_i (uart_rvalid_o     ),
        .s2_rready_o (xbar_s2_rready_o  ),
        .s2_awid_o   (xbar_s2_awid_o    ),
        .s2_awaddr_o (xbar_s2_awaddr_o  ),
        .s2_awlen_o  (xbar_s2_awlen_o   ),
        .s2_awsize_o (xbar_s2_awsize_o  ),
        .s2_awburst_o(xbar_s2_awburst_o ),
        .s2_awvalid_o(xbar_s2_awvalid_o ),
        .s2_awready_i(uart_awready_o    ),
        .s2_wid_o    (xbar_s2_wid_o     ),
        .s2_wdata_o  (xbar_s2_wdata_o   ),
        .s2_wstrb_o  (xbar_s2_wstrb_o   ),
        .s2_wlast_o  (xbar_s2_wlast_o   ),
        .s2_wvalid_o (xbar_s2_wvalid_o  ),
        .s2_wready_i (uart_wready_o     ),
        .s2_bid_i    (uart_bid_o        ),
        .s2_bresp_i  (uart_bresp_o      ),
        .s2_bvalid_i (uart_bvalid_o     ),
        .s2_bready_o (xbar_s2_bready_o  )
    );

    MEM  MEM_inst (
        .clk_i       (clock             ),
        .rst_n_i     (~reset            ),
        .arid_i      (xbar_s1_arid_o    ),
        .araddr_i    (xbar_s1_araddr_o  ),
        .arlen_i     (xbar_s1_arlen_o   ),
        .arsize_i    (xbar_s1_arsize_o  ),
        .arburst_i   (xbar_s1_arburst_o ),
        .arvalid_i   (xbar_s1_arvalid_o ),
        .arready_o   (mem_arready_o     ),
        .rid_o       (mem_rid_o         ),
        .rdata_o     (mem_rdata_o       ),
        .rresp_o     (mem_rresp_o       ),
        .rlast_o     (mem_rlast_o       ),
        .rvalid_o    (mem_rvalid_o      ),
        .rready_i    (xbar_s1_rready_o  ),
        .awid_i      (xbar_s1_awid_o    ),
        .awaddr_i    (xbar_s1_awaddr_o  ),
        .awlen_i     (xbar_s1_awlen_o   ),
        .awsize_i    (xbar_s1_awsize_o  ),
        .awburst_i   (xbar_s1_awburst_o ),
        .awvalid_i   (xbar_s1_awvalid_o ),
        .awready_o   (mem_awready_o     ),
        .wid_i       (xbar_s1_wid_o     ),
        .wdata_i     (xbar_s1_wdata_o   ),
        .wstrb_i     (xbar_s1_wstrb_o   ),
        .wlast_i     (xbar_s1_wlast_o   ),
        .wvalid_i    (xbar_s1_wvalid_o  ),
        .wready_o    (mem_wready_o      ),
        .bid_o       (mem_bid_o         ),
        .bresp_o     (mem_bresp_o       ),
        .bvalid_o    (mem_bvalid_o      ),
        .bready_i    (xbar_s1_bready_o  )
    );

    
    UART  UART_inst (
        .clk_i       (clock             ),
        .rst_n_i     (~reset            ),
        .arid_i      (xbar_s2_arid_o    ),
        .araddr_i    (xbar_s2_araddr_o  ),
        .arlen_i     (xbar_s2_arlen_o   ),
        .arsize_i    (xbar_s2_arsize_o  ),
        .arburst_i   (xbar_s2_arburst_o ),
        .arvalid_i   (xbar_s2_arvalid_o ),
        .arready_o   (uart_arready_o    ),
        .rid_o       (uart_rid_o        ),
        .rdata_o     (uart_rdata_o      ),
        .rresp_o     (uart_rresp_o      ),
        .rlast_o     (uart_rlast_o      ),
        .rvalid_o    (uart_rvalid_o     ),
        .rready_i    (xbar_s2_rready_o  ),
        .awid_i      (xbar_s2_awid_o    ),
        .awaddr_i    (xbar_s2_awaddr_o  ),
        .awlen_i     (xbar_s2_awlen_o   ),
        .awsize_i    (xbar_s2_awsize_o  ),
        .awburst_i   (xbar_s2_awburst_o ),
        .awvalid_i   (xbar_s2_awvalid_o ),
        .awready_o   (uart_awready_o    ),
        .wid_i       (xbar_s2_wid_o     ),
        .wdata_i     (xbar_s2_wdata_o   ),
        .wstrb_i     (xbar_s2_wstrb_o   ),
        .wlast_i     (xbar_s2_wlast_o   ),
        .wvalid_i    (xbar_s2_wvalid_o  ),
        .wready_o    (uart_wready_o     ),
        .bid_o       (uart_bid_o        ),
        .bresp_o     (uart_bresp_o      ),
        .bvalid_o    (uart_bvalid_o     ),
        .bready_i    (xbar_s2_bready_o  )
    );
    

    CLINT  CLINT_inst (
        .clk_i       (clock             ),
        .rst_n_i     (~reset            ),
        .arid_i      (xbar_s0_arid_o    ),
        .araddr_i    (xbar_s0_araddr_o  ),
        .arlen_i     (xbar_s0_arlen_o   ),
        .arsize_i    (xbar_s0_arsize_o  ),
        .arburst_i   (xbar_s0_arburst_o ),
        .arvalid_i   (xbar_s0_arvalid_o ),
        .arready_o   (clint_arready_o   ),
        .rid_o       (clint_rid_o       ),
        .rdata_o     (clint_rdata_o     ),
        .rresp_o     (clint_rresp_o     ),
        .rlast_o     (clint_rlast_o     ),
        .rvalid_o    (clint_rvalid_o    ),
        .rready_i    (xbar_s0_rready_o  ),
        .awid_i      (xbar_s0_awid_o    ),
        .awaddr_i    (xbar_s0_awaddr_o  ),
        .awlen_i     (xbar_s0_awlen_o   ),
        .awsize_i    (xbar_s0_awsize_o  ),
        .awburst_i   (xbar_s0_awburst_o ),
        .awvalid_i   (xbar_s0_awvalid_o ),
        .awready_o   (clint_awready_o   ),
        .wid_i       (xbar_s0_wid_o     ),
        .wdata_i     (xbar_s0_wdata_o   ),
        .wstrb_i     (xbar_s0_wstrb_o   ),
        .wlast_i     (xbar_s0_wlast_o   ),
        .wvalid_i    (xbar_s0_wvalid_o  ),
        .wready_o    (clint_wready_o    ),
        .bid_o       (clint_bid_o       ),
        .bresp_o     (clint_bresp_o     ),
        .bvalid_o    (clint_bvalid_o    ),
        .bready_i    (xbar_s0_bready_o  )
    );

endmodule       
  
