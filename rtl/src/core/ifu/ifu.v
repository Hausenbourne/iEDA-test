module ifu(
    //from top
    input           clk_i    ,
    input           rst_n_i  ,
    //from exu
    input   [31: 0] next_pc_i, 
    //to idu
    output  [31: 0] pc_o     ,
    output  [31: 0] inst_o   ,
    //from wbu
    input           done_i   ,
    //Handshake signal
    output          valid_o  ,
    input           ready_i  ,
    //from or to AXI_arbiter
    output  [ 3: 0] arid_o   ,
    output  [31: 0] araddr_o ,
    output  [ 7: 0] arlen_o  ,
    output  [ 2: 0] arsize_o ,
    output  [ 1: 0] arburst_o,    
    output          arvalid_o,
    input           arready_i,

    input   [ 3: 0] rid_i    ,
    input   [31: 0] rdata_i  ,
    input   [ 1: 0] rresp_i  ,
    input           rlast_i  ,
    input           rvalid_i ,
    output          rready_o
);

    wire    [31: 0] pc_pc    ;
    wire            pc_ena   ;

    wire            rst_i = ~ rst_n_i;

    pc  pc_inst (
        .clk_i    (clk_i    ),
        .rst_n_i  (rst_n_i  ),
        .ena_i    (pc_ena   ),
        .next_pc_i(next_pc_i),
        .pc_o     (pc_pc    )
    );

    /*    
    ifu_control  ifu_control_inst (
        .clk_i    (clk_i    ),
        .rst_n_i  (rst_n_i  ),
        .pc_i     (pc_pc    ),
        .ena_o    (pc_ena   ),
        .inst_o   (inst_o   ),
        .valid_o  (valid_o  ),
        .ready_i  (ready_i  ),
        .done_i   (done_i   ),
        .arid_o   (arid_o   ),
        .araddr_o (araddr_o ),
        .arlen_o  (arlen_o  ),
        .arsize_o (arsize_o ),
        .arburst_o(arburst_o),
        .arvalid_o(arvalid_o),
        .arready_i(arready_i),
        .rid_i    (rid_i    ),
        .rdata_i  (rdata_i  ),
        .rresp_i  (rresp_i  ),
        .rlast_i  (rlast_i  ),
        .rvalid_i (rvalid_i ),
        .rready_o (rready_o )
    );
    */
    
    
    assign pc_o = pc_pc;
    

    
    wire [31: 0] o_ifu_control_araddr;
    wire [ 7: 0] o_ifu_control_arlen;
    wire [ 2: 0] o_ifu_control_arsize;
    wire [ 1: 0] o_ifu_control_arburst;
    wire         o_ifu_control_arvalid;
    wire         o_ifu_control_rready;


    wire         o_icache_arready;
    wire [31: 0] o_icache_rdata;
    wire [ 1: 0] o_icache_rresp;
    wire         o_icache_rvalid;
    wire [31: 0] o_icache_araddr;
    wire [ 7: 0] o_icache_arlen;
    wire [ 2: 0] o_icache_arsize;
    wire [ 1: 0] o_icache_arburst;
    wire         o_icache_arvalid;
    wire         o_icache_rready;
    
    ifu_control  ifu_control_inst (
        .clk_i    (clk_i    ),
        .rst_n_i  (rst_n_i  ),
        .pc_i     (pc_pc    ),
        .ena_o    (pc_ena   ),
        .inst_o   (inst_o   ),
        .valid_o  (valid_o  ),
        .ready_i  (ready_i  ),
        .done_i   (done_i   ),
        .arid_o   (         ),
        .araddr_o (o_ifu_control_araddr ),
        .arlen_o  (o_ifu_control_arlen  ),
        .arsize_o (o_ifu_control_arsize ),
        .arburst_o(o_ifu_control_arburst),
        .arvalid_o(o_ifu_control_arvalid),
        .arready_i(o_icache_arready     ),
        .rid_i    (                     ),
        .rdata_i  (o_icache_rdata       ),
        .rresp_i  (o_icache_rresp       ),
        .rlast_i  (                     ),
        .rvalid_i (o_icache_rvalid      ),
        .rready_o (o_ifu_control_rready )
    );

    ICache  ICache_inst (
        .i_clk    (clk_i           ),
        .i_rst    (rst_i           ),
        .i_araddr (o_ifu_control_araddr ),
        .i_arvalid(o_ifu_control_arvalid),
        .o_arready(o_icache_arready),
        .o_rdata  (o_icache_rdata  ),
        .o_rresp  (o_icache_rresp  ),
        .o_rvalid (o_icache_rvalid ),
        .i_rready (o_ifu_control_rready),
        .o_araddr (o_icache_araddr ),
        .o_arlen  (o_icache_arlen  ),
        .o_arsize (o_icache_arsize ),
        .o_arburst(o_icache_arburst),
        .o_arvalid(o_icache_arvalid),
        .i_arready(arready_i),
        .i_rdata  (rdata_i  ),
        .i_rresp  (rresp_i  ),
        .i_rlast  (rlast_i  ),
        .i_rvalid (rvalid_i ),
        .o_rready (o_icache_rready )
    );
    

    assign araddr_o = o_icache_araddr  ;
    assign arlen_o  = o_icache_arlen   ;
    assign arsize_o = o_icache_arsize  ;
    assign arburst_o = o_icache_arburst;
    assign arvalid_o = o_icache_arvalid;
    assign rready_o = o_icache_rready;
    
endmodule




