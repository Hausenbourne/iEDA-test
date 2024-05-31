//`include "/home/bourne/ysyx-workbench/npc/vsrc/alu.v"
`include "defines.v"

module core_top(                                                                                                                                 
    input          clk_i      ,
    input          rst_n_i    ,
    //AXI-lite
    output [ 3: 0] arid_o     ,
    output [31: 0] araddr_o   ,
    output [ 7: 0] arlen_o    ,
    output [ 2: 0] arsize_o   ,
    output [ 1: 0] arburst_o  ,
    output         arvalid_o  ,
    input          arready_i  ,

    input  [ 3: 0] rid_i      ,
    input  [31: 0] rdata_i    ,
    input  [ 1: 0] rresp_i    ,
    input          rlast_i    ,
    input          rvalid_i   ,
    output         rready_o   ,

    output [ 3: 0] awid_o     ,
    output [31: 0] awaddr_o   ,
    output [ 7: 0] awlen_o    ,
    output [ 2: 0] awsize_o   ,
    output [ 1: 0] awburst_o  ,
    output         awvalid_o  ,
    input          awready_i  ,

    output [ 3: 0] wid_o      ,
    output [31: 0] wdata_o    ,
    output [ 3: 0] wstrb_o    ,
    output         wlast_o    ,
    output         wvalid_o   ,
    input          wready_i   ,

    input  [ 3: 0] bid_i      ,
    input  [ 1: 0] bresp_i    ,
    input          bvalid_i   ,
    output         bready_o   
  );
    //ifu模块输出信号
    wire [31: 0] ifu_pc_o     ;
    wire [31: 0] ifu_inst_o   ;
    wire         ifu_valid_o  ;
    wire [ 3: 0] ifu_arid_o   ;
    wire [31: 0] ifu_araddr_o ;
    wire [ 7: 0] ifu_arlen_o  ;
    wire [ 2: 0] ifu_arsize_o ;
    wire [ 1: 0] ifu_arburst_o;
    wire         ifu_arvalid_o;
    wire         ifu_rready_o ;
  
    //idu模块输出信号
    wire        o_idu_reg_wena;
    wire [ 1:0] o_idu_reg_sel;
    //wire  [ 2:0] o_idu_wbu_package;
    wire        o_idu_MemWr;
    wire [ 2:0] o_idu_MemOp;
    wire        o_idu_MemRe;
    //wire  [ 3:0] o_idu_lsu_package;
    wire        o_idu_pc_sel;
    wire [ 2:0] o_idu_branch;
    wire [ 3:0] o_idu_alu_ctr;
    wire        o_idu_ALUAsrc;
    wire [ 1:0] o_idu_ALUBsrc;
    //wire  [10:0] o_idu_exu_package;
  
    wire [31:0] o_idu_pc;
    wire [31:0] o_idu_imm;
    wire [31:0] o_idu_src1;
    wire [31:0] o_idu_src2;
    wire [31:0] o_idu_inst;
    wire        o_idu_ready;
    wire        o_idu_valid;
  
    wire [ 4:0] o_idu_reg1_raddr;
    wire [ 4:0] o_idu_reg2_raddr;
    //exu模块输出信号 
    wire [31:0] o_exu_next_pc;
  
    /* verilator lint_off UNOPTFLAT */
    wire        o_exu_reg_wena;
    //组合逻辑回路，由exu输出，又回到exu
     /* verilator lint_on UNOPTFLAT */
    wire [ 1:0] o_exu_reg_sel;
  
    wire        o_exu_MemWr;
    wire [ 2:0] o_exu_MemOp;
    wire        o_exu_MemRe;
  
    wire [31:0] o_exu_ALUout;
    wire [31:0] o_exu_pc;
    wire [31:0] o_exu_imm;
    wire [31:0] o_exu_src1;
    wire [31:0] o_exu_src2;
    wire [31:0] o_exu_inst;
    wire        o_exu_ready;
    wire        o_exu_valid;
    //lsu模块输出信号
    wire        lsu_reg_wena_o;
    wire [ 1:0] lsu_reg_sel_o;
  
    wire [31:0] lsu_mem_rdata_o;
    wire [31:0] lsu_ALUout_o;
    wire [31:0] lsu_pc_o;
    wire [31:0] lsu_imm_o;
    wire [31:0] lsu_src1_o;
    wire [31:0] lsu_inst_o;
    wire        lsu_ready_o;
    wire        lsu_valid_o;
  
    wire [ 3:0] lsu_arid_o;
    wire [31:0] lsu_araddr_o;
    wire [ 7:0] lsu_arlen_o;
    wire [ 2:0] lsu_arsize_o;
    wire [ 1:0] lsu_arburst_o;
    wire        lsu_arvalid_o;
    wire        lsu_rready_o;
    wire [ 3:0] lsu_awid_o;
    wire [31:0] lsu_awaddr_o;
    wire [ 7:0] lsu_awlen_o;
    wire [ 2:0] lsu_awsize_o;
    wire [ 1:0] lsu_awburst_o;
    wire        lsu_awvalid_o;
    wire [ 3:0] lsu_wid_o;
    wire [31:0] lsu_wdata_o;
    wire [3 :0] lsu_wstrb_o;
    wire        lsu_wlast_o;
    wire        lsu_wvalid_o;
    wire        lsu_bready_o;
  
    //wbu模块输出信号
    wire [31:0] o_wbu_reg_wdata;
    wire [ 4:0] o_wbu_reg_waddr;
    wire        o_wbu_reg_wena;
    wire [31:0] o_wbu_csr_src;
    wire        o_wbu_done;
    wire        o_wbu_ready;
      
    //regfile输出信号
    wire [31:0] o_regfile_reg1_rdata;
    wire [31:0] o_regfile_reg2_rdata;

    //ICache输出信号
    /*
    wire        o_icache_arready;
    wire [31:0] o_icache_rdata;
    wire [ 1:0] o_icache_rresp;
    wire        o_icache_rvalid;
    wire [31:0] o_icache_araddr;
    wire [ 7:0] o_icache_arlen;
    wire [ 2:0] o_icache_arsize;
    wire [ 1:0] o_icache_arburst;
    wire        o_icache_arvalid;
    wire        o_icache_rready;
    */

    //RNG 输出信号
    //wire [31:0] o_rng_rand;
 
    //arbiter输出信号
    wire         arbiter_m0_arready_o;
    wire [ 3: 0] arbiter_m0_rid_o    ;
    wire [31: 0] arbiter_m0_rdata_o  ;
    wire [ 1: 0] arbiter_m0_rresp_o  ;
    wire         arbiter_m0_rlast_o  ;
    wire         arbiter_m0_rvalid_o ;
      
    //wire         arbiter_m0_awready_o;
    //wire         arbiter_m0_wready_o ;
    //wire [ 3: 0] arbiter_m0_bid_o    ;
    //wire [ 1: 0] arbiter_m0_bresp_o  ;
    //wire         arbiter_m0_bvalid_o ;
      
    wire         arbiter_m1_arready_o;
    wire [ 3: 0] arbiter_m1_rid_o    ;
    wire [31: 0] arbiter_m1_rdata_o  ;
    wire [ 1: 0] arbiter_m1_rresp_o  ;
    wire         arbiter_m1_rlast_o  ;
    wire         arbiter_m1_rvalid_o ;
      
    wire         arbiter_m1_awready_o;
    wire         arbiter_m1_wready_o ;
    wire [ 3: 0] arbiter_m1_bid_o    ;
    wire [ 1: 0] arbiter_m1_bresp_o  ;
    wire         arbiter_m1_bvalid_o ;

    //wire [ 3: 0] arbiter_arid_o      ;
    //wire [31: 0] arbiter_araddr_o    ;
    //wire [ 7: 0] arbiter_arlen_o     ;
    //wire [ 2: 0] arbiter_arsize_o    ;
    //wire [ 1: 0] arbiter_arburst_o   ;
    //wire         arbiter_arvalid_o   ;
    //wire         arbiter_rready_o    ;
    //wire [ 3: 0] arbiter_awid_o      ;
    //wire [31: 0] arbiter_awaddr_o    ;
    //wire [ 7: 0] arbiter_awlen_o     ;
    //wire [ 2: 0] arbiter_awsize_o    ;
    //wire [ 1: 0] arbiter_awburst_o   ;
    //wire         arbiter_awvalid_o   ;
    //wire [ 3: 0] arbiter_wid_o       ;
    //wire [31: 0] arbiter_wdata_o     ;
    //wire [ 3: 0] arbiter_wstrb_o     ;
    //wire         arbiter_wlast_o     ;
    //wire         arbiter_wvalid_o    ;
    //wire         arbiter_bready_o    ;

      
     
  
    ifu  ifu_inst (
        .clk_i    (clk_i               ),
        .rst_n_i  (rst_n_i             ),
        .next_pc_i(o_exu_next_pc       ),
        .pc_o     (ifu_pc_o            ),
        .inst_o   (ifu_inst_o          ),
        .done_i   (o_wbu_done          ),
        .valid_o  (ifu_valid_o         ),
        .ready_i  (o_idu_ready         ),

        .arid_o   (ifu_arid_o          ),
        .araddr_o (ifu_araddr_o        ),
        .arlen_o  (ifu_arlen_o         ),
        .arsize_o (ifu_arsize_o        ),
        .arburst_o(ifu_arburst_o       ),
        .arvalid_o(ifu_arvalid_o       ),

        .arready_i(arbiter_m0_arready_o),
        .rid_i    (arbiter_m0_rid_o    ),
        .rdata_i  (arbiter_m0_rdata_o  ),
        .rresp_i  (arbiter_m0_rresp_o  ),
        .rlast_i  (arbiter_m0_rlast_o  ),
        .rvalid_i (arbiter_m0_rvalid_o ),

        .rready_o (ifu_rready_o        )
    );
  
    idu  idu_inst (
        .i_clk(clk_i ),
        .i_rst(~rst_n_i),
        .i_pc(ifu_pc_o),
        .i_inst(ifu_inst_o),
  
        .o_reg_wena(o_idu_reg_wena),
        .o_reg_sel(o_idu_reg_sel),
        //.o_wbu_package(o_idu_wbu_package),
        .o_MemOp(o_idu_MemOp),
        .o_MemWr(o_idu_MemWr),
        .o_MemRe(o_idu_MemRe),
        //.o_lsu_package(o_idu_lsu_package),
  
        .o_pc_sel(o_idu_pc_sel),
        .o_branch(o_idu_branch),
        .o_alu_ctr(o_idu_alu_ctr),
        .o_ALUAsrc(o_idu_ALUAsrc),
        .o_ALUBsrc(o_idu_ALUBsrc),
        //.o_exu_package(o_idu_exu_package),
  
        .o_pc(o_idu_pc),
        .o_imm(o_idu_imm),
        .o_src1(o_idu_src1),
        .o_src2(o_idu_src2),
        .o_inst(o_idu_inst),
  
        .o_reg1_raddr(o_idu_reg1_raddr),
        .o_reg2_raddr(o_idu_reg2_raddr),
        .i_reg1_rdata(o_regfile_reg1_rdata),
        .i_reg2_rdata(o_regfile_reg2_rdata),
  
        .i_valid(ifu_valid_o),
        .o_ready(o_idu_ready),
  
        .o_valid(o_idu_valid),
        .i_ready(o_exu_ready)
    );
  
  
    exu  exu_inst (
        .i_clk(clk_i ),
        .i_rst(~rst_n_i),
        .o_next_pc (o_exu_next_pc),
        .i_csr_src (o_wbu_csr_src),
  
        .i_reg_wena(o_idu_reg_wena),
        .i_reg_sel (o_idu_reg_sel),
        //.i_wbu_package(o_idu_wbu_package),
  
        .i_MemWr   (o_idu_MemWr),
        .i_MemOp   (o_idu_MemOp),
        .i_MemRe   (o_idu_MemRe),
        //.i_lsu_package(o_idu_lsu_package),
  
        .i_pc_sel  (o_idu_pc_sel),
        .i_branch  (o_idu_branch),
        .i_alu_ctr (o_idu_alu_ctr),
        .i_ALUAsrc (o_idu_ALUAsrc),
        .i_ALUBsrc (o_idu_ALUBsrc),
        //.i_exu_package(o_idu_exu_package),
  
        .i_pc      (o_idu_pc),
        .i_imm     (o_idu_imm),
        .i_src1    (o_idu_src1),
        .i_src2    (o_idu_src2),
        .i_inst    (o_idu_inst),
  
        .o_reg_wena(o_exu_reg_wena),
        .o_reg_sel (o_exu_reg_sel),
        //.o_wbu_package(o_exu_wbu_package),
  
        .o_MemWr   (o_exu_MemWr),
        .o_MemOp   (o_exu_MemOp),
        .o_MemRe   (o_exu_MemRe),
        //.o_lsu_package(o_exu_lsu_package),
  
        .o_ALUout  (o_exu_ALUout),
        .o_pc      (o_exu_pc),
        .o_imm     (o_exu_imm),
        .o_src1    (o_exu_src1),
        .o_src2    (o_exu_src2),
        .o_inst    (o_exu_inst),
   
        .i_valid   (o_idu_valid),
        .o_ready   (o_exu_ready),
     
        .o_valid   (o_exu_valid),
        .i_ready   (lsu_ready_o)
    );
  
  
    lsu  lsu_inst (
        .clk_i      (clk_i               ),
        .rst_n_i    (rst_n_i             ),
        .reg_wena_i (o_exu_reg_wena      ),
        .reg_sel_i  (o_exu_reg_sel       ),
        .MemWr_i    (o_exu_MemWr         ),
        .MemOp_i    (o_exu_MemOp         ),
        .MemRe_i    (o_exu_MemRe         ),
        .ALUout_i   (o_exu_ALUout        ),
        .pc_i       (o_exu_pc            ),
        .imm_i      (o_exu_imm           ),
        .src1_i     (o_exu_src1          ),
        .src2_i     (o_exu_src2          ),
        .inst_i     (o_exu_inst          ),
        .valid_i    (o_exu_valid         ),
        .ready_o    (lsu_ready_o         ),
        .reg_wena_o (lsu_reg_wena_o      ),
        .reg_sel_o  (lsu_reg_sel_o       ),
        .mem_rdata_o(lsu_mem_rdata_o     ),
        .ALUout_o   (lsu_ALUout_o        ),
        .pc_o       (lsu_pc_o            ),
        .imm_o      (lsu_imm_o           ),
        .src1_o     (lsu_src1_o          ),
        .inst_o     (lsu_inst_o          ),
        .valid_o    (lsu_valid_o         ),
        .ready_i    (o_wbu_ready         ),
        .arid_o     (lsu_arid_o          ),
        .araddr_o   (lsu_araddr_o        ),
        .arlen_o    (lsu_arlen_o         ),
        .arsize_o   (lsu_arsize_o        ),
        .arburst_o  (lsu_arburst_o       ),
        .arvalid_o  (lsu_arvalid_o       ),
        .arready_i  (arbiter_m1_arready_o),
        .rid_i      (arbiter_m1_rid_o    ),
        .rdata_i    (arbiter_m1_rdata_o  ),
        .rresp_i    (arbiter_m1_rresp_o  ),
        .rlast_i    (arbiter_m1_rlast_o  ),
        .rvalid_i   (arbiter_m1_rvalid_o ),
        .rready_o   (lsu_rready_o        ),
        .awid_o     (lsu_awid_o          ),
        .awaddr_o   (lsu_awaddr_o        ),
        .awlen_o    (lsu_awlen_o         ),
        .awsize_o   (lsu_awsize_o        ),
        .awburst_o  (lsu_awburst_o       ),
        .awvalid_o  (lsu_awvalid_o       ),
        .awready_i  (arbiter_m1_awready_o),
        .wid_o      (lsu_wid_o           ),
        .wdata_o    (lsu_wdata_o         ),
        .wstrb_o    (lsu_wstrb_o         ),
        .wlast_o    (lsu_wlast_o         ),
        .wvalid_o   (lsu_wvalid_o        ),
        .wready_i   (arbiter_m1_wready_o ),
        .bid_i      (arbiter_m1_bid_o    ),
        .bresp_i    (arbiter_m1_bresp_o  ),
        .bvalid_i   (arbiter_m1_bvalid_o ),
        .bready_o   (lsu_bready_o        )
    );
  
  
    wbu  wbu_inst (
        .i_clk      (clk_i),
        .i_rst_n    (rst_n_i),
  
        .i_reg_wena (lsu_reg_wena_o),
        .i_reg_sel  (lsu_reg_sel_o),
        //.i_wbu_package(o_lsu_wbu_package),
  
        .i_mem_rdata(lsu_mem_rdata_o),
        .i_ALUout   (lsu_ALUout_o),
        .i_pc       (lsu_pc_o),
        .i_imm      (lsu_imm_o),
        .i_src1     (lsu_src1_o),
        .i_inst     (lsu_inst_o),
        .o_reg_wdata(o_wbu_reg_wdata),
        .o_reg_waddr(o_wbu_reg_waddr),
        .o_reg_wena (o_wbu_reg_wena),
        .o_done     (o_wbu_done),
        .o_csr_src  (o_wbu_csr_src),
  
        .i_valid    (lsu_valid_o),
        .o_ready    (o_wbu_ready)
    );
  
  
    regfile  regfile_inst (
        .i_clk       (clk_i),
        .i_rst_n     (rst_n_i),
        .i_reg1_raddr(o_idu_reg1_raddr),
        .o_reg1_rdata(o_regfile_reg1_rdata),
        .i_reg2_raddr(o_idu_reg2_raddr),
        .o_reg2_rdata(o_regfile_reg2_rdata),
        .i_reg_waddr (o_wbu_reg_waddr),
        .i_reg_wdata (o_wbu_reg_wdata),
        .i_reg_wena  (o_wbu_reg_wena)
    );


    /*
    ICache  ICache_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_rand(o_rng_rand[1:0]),
        .i_araddr(o_ifu_araddr),
        .i_arvalid(o_ifu_arvalid),
        .o_arready(o_icache_arready),
        .o_rdata(o_icache_rdata),
        .o_rresp(o_icache_rresp),
        .o_rvalid(o_icache_rvalid),
        .i_rready(o_ifu_rready),
        .o_araddr(o_icache_araddr),
        .o_arlen(o_icache_arlen),
        .o_arsize(o_icache_arsize),
        .o_arburst(o_icache_arburst),
        .o_arvalid(o_icache_arvalid),
        .i_arready(o_sram_arready),
        .i_rdata(o_sram_rdata),
        .i_rresp(o_sram_rresp),
        .i_rlast(o_sram_rlast),
        .i_rvalid(o_sram_rvalid),
        .o_rready(o_icache_rready)
  );
  */
  

    

    /*
    RNG  RNG_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .o_rand(o_rng_rand)
    );
    */


    arbiter  arbiter_inst (
        .clk_i       (clk_i               ),
        .rst_n_i     (rst_n_i             ),
        .m0_arid_i   (ifu_arid_o          ),
        .m0_araddr_i (ifu_araddr_o        ),
        .m0_arlen_i  (ifu_arlen_o         ),
        .m0_arsize_i (ifu_arsize_o        ),
        .m0_arburst_i(ifu_arburst_o       ),
        .m0_arvalid_i(ifu_arvalid_o       ),
        .m0_arready_o(arbiter_m0_arready_o),
        .m0_rid_o    (arbiter_m0_rid_o    ),
        .m0_rdata_o  (arbiter_m0_rdata_o  ),
        .m0_rresp_o  (arbiter_m0_rresp_o  ),
        .m0_rlast_o  (arbiter_m0_rlast_o  ),
        .m0_rvalid_o (arbiter_m0_rvalid_o ),
        .m0_rready_i (ifu_rready_o        ),
        .m0_awid_i   (                    ),
        .m0_awaddr_i (                    ),
        .m0_awlen_i  (                    ),
        .m0_awsize_i (                    ),
        .m0_awburst_i(                    ),
        .m0_awvalid_i(                    ),
        .m0_awready_o(                    ),
        .m0_wid_i    (                    ),
        .m0_wdata_i  (                    ),
        .m0_wstrb_i  (                    ),
        .m0_wlast_i  (                    ),
        .m0_wvalid_i (                    ),
        .m0_wready_o (                    ),
        .m0_bid_o    (                    ),
        .m0_bresp_o  (                    ),
        .m0_bvalid_o (                    ),
        .m0_bready_i (                    ),
        .m1_arid_i   (lsu_arid_o          ),
        .m1_araddr_i (lsu_araddr_o        ),
        .m1_arlen_i  (lsu_arlen_o         ),
        .m1_arsize_i (lsu_arsize_o        ),
        .m1_arburst_i(lsu_arburst_o       ),
        .m1_arvalid_i(lsu_arvalid_o       ),
        .m1_arready_o(arbiter_m1_arready_o),
        .m1_rid_o    (arbiter_m1_rid_o    ),
        .m1_rdata_o  (arbiter_m1_rdata_o  ),
        .m1_rresp_o  (arbiter_m1_rresp_o  ),
        .m1_rlast_o  (arbiter_m1_rlast_o  ),
        .m1_rvalid_o (arbiter_m1_rvalid_o ),
        .m1_rready_i (lsu_rready_o        ),
        .m1_awid_i   (lsu_awid_o          ),
        .m1_awaddr_i (lsu_awaddr_o        ),
        .m1_awlen_i  (lsu_awlen_o         ),
        .m1_awsize_i (lsu_awsize_o        ),
        .m1_awburst_i(lsu_awburst_o       ),
        .m1_awvalid_i(lsu_awvalid_o       ),
        .m1_awready_o(arbiter_m1_awready_o),
        .m1_wid_i    (lsu_wid_o           ),
        .m1_wdata_i  (lsu_wdata_o         ),
        .m1_wstrb_i  (lsu_wstrb_o         ),
        .m1_wlast_i  (lsu_wlast_o         ),
        .m1_wvalid_i (lsu_wvalid_o        ),
        .m1_wready_o (arbiter_m1_wready_o ),
        .m1_bid_o    (arbiter_m1_bid_o    ),
        .m1_bresp_o  (arbiter_m1_bresp_o  ),
        .m1_bvalid_o (arbiter_m1_bvalid_o ),
        .m1_bready_i (lsu_bready_o        ),

        .arid_o      (arid_o              ),
        .araddr_o    (araddr_o            ),
        .arlen_o     (arlen_o             ),
        .arsize_o    (arsize_o            ),
        .arburst_o   (arburst_o           ),
        .arvalid_o   (arvalid_o           ),
        .arready_i   (arready_i           ),
        .rid_i       (rid_i               ),
        .rdata_i     (rdata_i             ),
        .rresp_i     (rresp_i             ),
        .rlast_i     (rlast_i             ),
        .rvalid_i    (rvalid_i            ),
        .rready_o    (rready_o            ),
        .awid_o      (awid_o              ),
        .awaddr_o    (awaddr_o            ),
        .awlen_o     (awlen_o             ),
        .awsize_o    (awsize_o            ),
        .awburst_o   (awburst_o           ),
        .awvalid_o   (awvalid_o           ),
        .awready_i   (awready_i           ),
        .wid_o       (wid_o               ),
        .wdata_o     (wdata_o             ),
        .wstrb_o     (wstrb_o             ),
        .wlast_o     (wlast_o             ),
        .wvalid_o    (wvalid_o            ),
        .wready_i    (wready_i            ),
        .bid_i       (bid_i               ),
        .bresp_i     (bresp_i             ),
        .bvalid_i    (bvalid_i            ),
        .bready_o    (bready_o            )
    );


  
   
endmodule           
  
