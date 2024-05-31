module lsu(
    input          clk_i       ,
    input          rst_n_i     ,
    //from exu
    input          reg_wena_i  ,
    input  [ 1: 0] reg_sel_i   ,
 
    input          MemWr_i     ,
    input  [ 2: 0] MemOp_i     ,
    input          MemRe_i     ,/////////////////////前面的模块也要添加这个信号
 
    input  [31: 0] ALUout_i    ,
    input  [31: 0] pc_i        ,
    input  [31: 0] imm_i       ,
 
    input  [31: 0] src1_i      ,
    input  [31: 0] src2_i      ,
 
    input  [31: 0] inst_i      ,
    input          valid_i     ,
    output         ready_o     ,
    
    //to wbu
    output         reg_wena_o  ,
    output [ 1: 0] reg_sel_o   ,

    output [31: 0] mem_rdata_o ,
    output [31: 0] ALUout_o    ,
    output [31: 0] pc_o        ,
    output [31: 0] imm_o       ,
    output [31: 0] src1_o      ,
    output [31: 0] inst_o      ,
   
    output         valid_o     ,
    input          ready_i     ,
    
    //from or to AXI_arbiter
    output [ 3: 0] arid_o      ,
    output [31: 0] araddr_o    ,
    output [ 7: 0] arlen_o     ,
    output [ 2: 0] arsize_o    ,
    output [ 1: 0] arburst_o   ,
    output         arvalid_o   ,
    input          arready_i   ,
   
    input  [ 3: 0] rid_i       ,
    input  [31: 0] rdata_i     ,
    input  [ 1: 0] rresp_i     ,
    input          rlast_i     ,
    input          rvalid_i    ,
    output         rready_o    ,
   
    output [ 3: 0] awid_o      ,
    output [31: 0] awaddr_o    ,
    output [ 7: 0] awlen_o     ,
    output [ 2: 0] awsize_o    ,
    output [ 1: 0] awburst_o   ,
    output         awvalid_o   ,
    input          awready_i   ,
   
    output [ 3: 0] wid_o       ,
    output [31: 0] wdata_o     ,
    output [ 3: 0] wstrb_o     ,
    output         wlast_o     ,
    output         wvalid_o    ,
    input          wready_i    ,

    input  [ 3: 0] bid_i       ,
    input  [ 1: 0] bresp_i     ,
    input          bvalid_i    ,
    output         bready_o    

);

    lsu_control  lsu_control_inst (
        .clk_i      (clk_i      ),
        .rst_n_i    (rst_n_i    ),
        .MemWr_i    (MemWr_i    ),
        .MemOp_i    (MemOp_i    ),
        .MemRe_i    (MemRe_i    ),
        .addr_i     (ALUout_i   ),
        .wdata_i    (src2_i     ),
        .valid_i    (valid_i    ),
        .ready_o    (ready_o    ),
        .arid_o     (arid_o     ),
        .araddr_o   (araddr_o   ),
        .arlen_o    (arlen_o    ),
        .arsize_o   (arsize_o   ),
        .arburst_o  (arburst_o  ),
        .arvalid_o  (arvalid_o  ),
        .arready_i  (arready_i  ),
        .rid_i      (rid_i      ),
        .rdata_i    (rdata_i    ),
        .rresp_i    (rresp_i    ),
        .rlast_i    (rlast_i    ),
        .rvalid_i   (rvalid_i   ),
        .rready_o   (rready_o   ),
        .awid_o     (awid_o     ),
        .awaddr_o   (awaddr_o   ),
        .awlen_o    (awlen_o    ),
        .awsize_o   (awsize_o   ),
        .awburst_o  (awburst_o  ),
        .awvalid_o  (awvalid_o  ),
        .awready_i  (awready_i  ),
        .wid_o      (wid_o      ),
        .wdata_o    (wdata_o    ),
        .wstrb_o    (wstrb_o    ),
        .wlast_o    (wlast_o    ),
        .wvalid_o   (wvalid_o   ),
        .wready_i   (wready_i   ),
        .bid_i      (bid_i      ),
        .bresp_i    (bresp_i    ),
        .bvalid_i   (bvalid_i   ),
        .bready_o   (bready_o   ),
        .mem_rdata_o(mem_rdata_o),
        .valid_o    (valid_o    ),
        .ready_i    (ready_i    )
    );

    //传递
    assign reg_wena_o = reg_wena_i;
    assign reg_sel_o  = reg_sel_i ;

    assign ALUout_o   = ALUout_i  ;
    assign pc_o       = pc_i      ;
    assign src1_o     = src1_i    ;
    assign inst_o     = inst_i    ;

    `ifdef SIMULATION
    import "DPI-C" function void LSU_TRACE(input bit wr, input int addr, input byte len, input bit[2:0] size, input int data, input bit[3:0] wstrb);
    always @(posedge clk_i) begin 
        if(wvalid_o & wready_i) begin
            LSU_TRACE(1'b1, awaddr_o, awlen_o, awsize_o , wdata_o, wstrb_o);
        end
        if(rvalid_i & rready_o) begin
            LSU_TRACE(1'b0, araddr_o, arlen_o, arsize_o , rdata_i, wstrb_o);
        end  
    end
    `endif

endmodule