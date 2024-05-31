module ysyx_23060001(
    input          clock            ,
    input          reset            ,
    input          io_interrupt     ,
    input          io_master_awready,
    output         io_master_awvalid,
    output [31: 0] io_master_awaddr ,
    output [ 3: 0] io_master_awid   ,
    output [ 7: 0] io_master_awlen  ,
    output [ 2: 0] io_master_awsize ,
    output [ 1: 0] io_master_awburst,
    input          io_master_wready ,
    output         io_master_wvalid ,
    output [63: 0] io_master_wdata  ,
    output [ 7: 0] io_master_wstrb  ,
    output         io_master_wlast  ,
    output         io_master_bready ,
    input          io_master_bvalid ,
    input  [ 1: 0] io_master_bresp  ,
    input  [ 3: 0] io_master_bid    ,
    input          io_master_arready,
    output         io_master_arvalid,
    output [31: 0] io_master_araddr ,
    output [ 3: 0] io_master_arid   ,
    output [ 7: 0] io_master_arlen  ,
    output [ 2: 0] io_master_arsize ,
    output [ 1: 0] io_master_arburst,
    output         io_master_rready ,
    input          io_master_rvalid ,
    input  [ 1: 0] io_master_rresp  ,
    input  [63: 0] io_master_rdata  ,
    input          io_master_rlast  ,
    input  [ 3: 0] io_master_rid    ,

    output         io_slave_awready,
    input          io_slave_awvalid,
    input  [31: 0] io_slave_awaddr ,
    input  [ 3: 0] io_slave_awid   ,
    input  [ 7: 0] io_slave_awlen  ,
    input  [ 2: 0] io_slave_awsize ,
    input  [ 1: 0] io_slave_awburst,
    output         io_slave_wready ,
    input          io_slave_wvalid ,
    input  [63: 0] io_slave_wdata  ,
    input  [ 7: 0] io_slave_wstrb  ,
    input          io_slave_wlast  ,
    input          io_slave_bready ,
    output         io_slave_bvalid ,
    output [ 1: 0] io_slave_bresp  ,
    output [ 3: 0] io_slave_bid    ,
    output         io_slave_arready,
    input          io_slave_arvalid,
    input  [31: 0] io_slave_araddr ,
    input  [ 3: 0] io_slave_arid   ,
    input  [ 7: 0] io_slave_arlen  ,
    input  [ 2: 0] io_slave_arsize ,
    input  [ 1: 0] io_slave_arburst,
    input          io_slave_rready ,
    output         io_slave_rvalid ,
    output [ 1: 0] io_slave_rresp  ,
    output [63: 0] io_slave_rdata  ,
    output         io_slave_rlast  ,
    output [ 3: 0] io_slave_rid    
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

    // AXI_Data_Width_Converter 输出信号
    wire         width_conv_arready_o ;
    wire [ 3: 0] width_conv_rid_o     ;
    wire [31: 0] width_conv_rdata_o   ;
    wire [ 1: 0] width_conv_rresp_o   ;
    wire         width_conv_rlast_o   ;
    wire         width_conv_rvalid_o  ;
    wire         width_conv_awready_o ;
    wire         width_conv_wready_o  ;
    wire [ 3: 0] width_conv_bid_o     ;
    wire [ 1: 0] width_conv_bresp_o   ;
    wire         width_conv_bvalid_o  ;

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

    Xbar  Xbar_inst (
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

        .s1_arid_o   (xbar_s1_arid_o      ),
        .s1_araddr_o (xbar_s1_araddr_o    ),
        .s1_arlen_o  (xbar_s1_arlen_o     ),
        .s1_arsize_o (xbar_s1_arsize_o    ),
        .s1_arburst_o(xbar_s1_arburst_o   ),
        .s1_arvalid_o(xbar_s1_arvalid_o   ),
        .s1_arready_i(width_conv_arready_o),
        .s1_rid_i    (width_conv_rid_o    ),
        .s1_rdata_i  (width_conv_rdata_o  ),
        .s1_rresp_i  (width_conv_rresp_o  ),
        .s1_rlast_i  (width_conv_rlast_o  ),
        .s1_rvalid_i (width_conv_rvalid_o ),
        .s1_rready_o (xbar_s1_rready_o    ),
        .s1_awid_o   (xbar_s1_awid_o      ),
        .s1_awaddr_o (xbar_s1_awaddr_o    ),
        .s1_awlen_o  (xbar_s1_awlen_o     ),
        .s1_awsize_o (xbar_s1_awsize_o    ),
        .s1_awburst_o(xbar_s1_awburst_o   ),
        .s1_awvalid_o(xbar_s1_awvalid_o   ),
        .s1_awready_i(width_conv_awready_o),
        .s1_wid_o    (xbar_s1_wid_o       ),
        .s1_wdata_o  (xbar_s1_wdata_o     ),
        .s1_wstrb_o  (xbar_s1_wstrb_o     ),
        .s1_wlast_o  (xbar_s1_wlast_o     ),
        .s1_wvalid_o (xbar_s1_wvalid_o    ),
        .s1_wready_i (width_conv_wready_o ),
        .s1_bid_i    (width_conv_bid_o    ),
        .s1_bresp_i  (width_conv_bresp_o  ),
        .s1_bvalid_i (width_conv_bvalid_o ),
        .s1_bready_o (xbar_s1_bready_o    )
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

    AXI_Data_Width_Converter  AXI_Data_Width_Converter_inst (
        .clk_i    (clock               ),
        .rst_n_i  (~reset              ),

        .arid_i   (xbar_s1_arid_o      ),
        .araddr_i (xbar_s1_araddr_o    ),
        .arlen_i  (xbar_s1_arlen_o     ),
        .arsize_i (xbar_s1_arsize_o    ),
        .arburst_i(xbar_s1_arburst_o   ),
        .arvalid_i(xbar_s1_arvalid_o   ),
        .arready_o(width_conv_arready_o),
        .rid_o    (width_conv_rid_o    ),
        .rdata_o  (width_conv_rdata_o  ),
        .rresp_o  (width_conv_rresp_o  ),
        .rlast_o  (width_conv_rlast_o  ),
        .rvalid_o (width_conv_rvalid_o ),
        .rready_i (xbar_s1_rready_o    ),
        .awid_i   (xbar_s1_awid_o      ),
        .awaddr_i (xbar_s1_awaddr_o    ),
        .awlen_i  (xbar_s1_awlen_o     ),
        .awsize_i (xbar_s1_awsize_o    ),
        .awburst_i(xbar_s1_awburst_o   ),
        .awvalid_i(xbar_s1_awvalid_o   ),
        .awready_o(width_conv_awready_o),
        .wid_i    (xbar_s1_wid_o       ),
        .wdata_i  (xbar_s1_wdata_o     ),
        .wstrb_i  (xbar_s1_wstrb_o     ),
        .wlast_i  (xbar_s1_wlast_o     ),
        .wvalid_i (xbar_s1_wvalid_o    ),
        .wready_o (width_conv_wready_o ),
        .bid_o    (width_conv_bid_o    ),
        .bresp_o  (width_conv_bresp_o  ),
        .bvalid_o (width_conv_bvalid_o ),
        .bready_i (xbar_s1_bready_o    ),

        .arid_o   (io_master_arid   ),
        .araddr_o (io_master_araddr ),
        .arlen_o  (io_master_arlen  ),
        .arsize_o (io_master_arsize ),
        .arburst_o(io_master_arburst),
        .arvalid_o(io_master_arvalid),
        .arready_i(io_master_arready),
        .rid_i    (io_master_rid    ),
        .rdata_i  (io_master_rdata  ),
        .rresp_i  (io_master_rresp  ),
        .rlast_i  (io_master_rlast  ),
        .rvalid_i (io_master_rvalid ),
        .rready_o (io_master_rready ),
        .awid_o   (io_master_awid   ),
        .awaddr_o (io_master_awaddr ),
        .awlen_o  (io_master_awlen  ),
        .awsize_o (io_master_awsize ),
        .awburst_o(io_master_awburst),
        .awvalid_o(io_master_awvalid),
        .awready_i(io_master_awready),
        .wid_o    (                 ),
        .wdata_o  (io_master_wdata  ),
        .wstrb_o  (io_master_wstrb  ),
        .wlast_o  (io_master_wlast  ),
        .wvalid_o (io_master_wvalid ),
        .wready_i (io_master_wready ),
        .bid_i    (io_master_bid    ),
        .bresp_i  (io_master_bresp  ),
        .bvalid_i (io_master_bvalid ),
        .bready_o (io_master_bready )
    );


endmodule