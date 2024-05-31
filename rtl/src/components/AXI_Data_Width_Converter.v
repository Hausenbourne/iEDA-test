module AXI_Data_Width_Converter(
    input          clk_i       ,
    input          rst_n_i     ,
    // from AXI 32 width
    input  [ 3: 0] arid_i      ,
    input  [31: 0] araddr_i    ,
    input  [ 7: 0] arlen_i     ,
    input  [ 2: 0] arsize_i    ,
    input  [ 1: 0] arburst_i   ,
    input          arvalid_i   ,
    output         arready_o   ,
    
    output [ 3: 0] rid_o       ,
    output [31: 0] rdata_o     ,
    output [ 1: 0] rresp_o     ,
    output         rlast_o     ,
    output         rvalid_o    ,
    input          rready_i    ,

    input  [ 3: 0] awid_i      ,
    input  [31: 0] awaddr_i    ,
    input  [ 7: 0] awlen_i     ,
    input  [ 2: 0] awsize_i    ,
    input  [ 1: 0] awburst_i   ,
    input          awvalid_i   ,
    output         awready_o   ,

    input  [ 3: 0] wid_i       ,
    input  [31: 0] wdata_i     ,
    input  [ 3: 0] wstrb_i     ,
    input          wlast_i     ,
    input          wvalid_i    ,
    output         wready_o    ,

    output [ 3: 0] bid_o       ,
    output [ 1: 0] bresp_o     ,
    output         bvalid_o    ,
    input          bready_i    ,
    // to AXI 64 width
    output [ 3: 0] arid_o      ,
    output [31: 0] araddr_o    ,
    output [ 7: 0] arlen_o     ,
    output [ 2: 0] arsize_o    ,
    output [ 1: 0] arburst_o   ,
    output         arvalid_o   ,
    input          arready_i   ,

    input  [ 3: 0] rid_i       ,
    input  [63: 0] rdata_i     ,
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
    output [63: 0] wdata_o     ,
    output [ 7: 0] wstrb_o     ,
    output         wlast_o     ,
    output         wvalid_o    ,
    input          wready_i    ,

    input  [ 3: 0] bid_i       ,
    input  [ 1: 0] bresp_i     ,
    input          bvalid_i    ,
    output         bready_o    
);

    // ===========================================================================
    // read
    wire         ar_offset_reg_c = clk_i                ;
    wire         ar_offset_reg_r = ~rst_n_i             ;
    wire [ 2: 0] ar_offset_reg_d = araddr_i[ 2: 0]      ;
    wire [ 2: 0] ar_offset_reg_q                        ;
    wire         ar_offset_reg_e = arvalid_i & arready_i;

    
    Reg # (3, 0) ar_offset_reg (
        .clk (ar_offset_reg_c )                         ,
        .rst (ar_offset_reg_r )                         ,
        .din (ar_offset_reg_d )                         ,
        .dout(ar_offset_reg_q )                         ,
        .wen (ar_offset_reg_e )
    );
    

    assign arid_o    = arid_i                           ;
    assign araddr_o  = araddr_i                         ;
    assign arlen_o   = arlen_i                          ;
    assign arsize_o  = arsize_i                         ;
    assign arburst_o = arburst_i                        ;
    assign arvalid_o = arvalid_i                        ;
    assign arready_o = arready_i                        ;

    assign rid_o     = rid_i                            ;
    
    assign rdata_o   = ar_offset_reg_q[2]               ?
                       rdata_i[63:32]: rdata_i[31: 0]   ;

    assign rresp_o   = rresp_i                          ;
    assign rlast_o   = rlast_i                          ;
    assign rvalid_o  = rvalid_i                         ;
    assign rready_o  = rready_i                         ;

    // ===========================================================================
    // write

    /*
    wire         aw_offset_reg_c = clk_i                ;
    wire         aw_offset_reg_r = ~rst_n_i             ;
    wire [ 2: 0] aw_offset_reg_d = awaddr_i[ 2: 0]      ;
    wire [ 2: 0] aw_offset_reg_q                        ;
    wire         aw_offset_reg_e = awvalid_i & awready_i;

    Reg # (3, 0) aw_offset_reg (
        .clk (aw_offset_reg_c )                         ,
        .rst (aw_offset_reg_r )                         ,
        .din (aw_offset_reg_d )                         ,
        .dout(aw_offset_reg_q )                         ,
        .wen (aw_offset_reg_e )
    );
    */
    wire [ 2: 0]  aw_offset = awaddr_i[ 2: 0]           ;

    assign awid_o    = awid_i                           ;
    assign awaddr_o  = awaddr_i                         ;
    assign awlen_o   = awlen_i                          ;
    assign awsize_o  = awsize_i                         ;
    assign awburst_o = awburst_i                        ;
    assign awvalid_o = awvalid_i                        ;
    assign awready_o = awready_i                        ;

    assign wid_o     = wid_i                            ;

    /*
    assign wdata_o   = ((aw_offset_reg_q == 3'b000) | 
                        (aw_offset_reg_q == 3'b001) | 
                        (aw_offset_reg_q == 3'b010) | 
                        (aw_offset_reg_q == 3'b011))? 
                        {32'b0, wdata_i}            :
                        {wdata_i, 32'b0}                ;

    assign wstrb_o   = ((aw_offset_reg_q == 3'b000) | 
                        (aw_offset_reg_q == 3'b001) | 
                        (aw_offset_reg_q == 3'b010) | 
                        (aw_offset_reg_q == 3'b011))? 
                        {4'b0, wstrb_i}             : 
                        {wstrb_i, 4'b0}                 ;
    */
    assign wdata_o   = ((aw_offset == 3'b000) | 
                        (aw_offset == 3'b001) | 
                        (aw_offset == 3'b010) | 
                        (aw_offset == 3'b011))? 
                        {32'b0, wdata_i}      :
                        {wdata_i, 32'b0}                ;

    assign wstrb_o   = ((aw_offset == 3'b000) | 
                        (aw_offset == 3'b001) | 
                        (aw_offset == 3'b010) | 
                        (aw_offset == 3'b011))? 
                        {4'b0, wstrb_i}       : 
                        {wstrb_i, 4'b0}                 ;

    assign wlast_o   = wlast_i                          ;
    assign wvalid_o  = wvalid_i                         ;
    assign wready_o  = wready_i                         ;
    
    assign bid_o     = bid_i                            ;
    assign bresp_o   = bresp_i                          ;
    assign bvalid_o  = bvalid_i                         ;
    assign bready_o  = bready_i                         ;

endmodule