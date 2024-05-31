module CLINT (
    input          clk_i       ,
    input          rst_n_i     ,
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
    input          bready_i
);
    wire rst = ~ rst_n_i       ;
    // ===========================================================================
    // state machine (just for read)
    parameter WAIT_ARVALID = 1'b0;
    parameter WAIT_RREADY  = 1'b1;

    reg state, n_state;

    always @(posedge clk_i) begin
        if(rst) begin
            state <= WAIT_ARVALID ;
        end
        else begin
            state <= n_state      ;
        end
    end

    always @(*) begin
        case (state)
            WAIT_ARVALID: n_state = arvalid_i? WAIT_RREADY : WAIT_ARVALID;
            WAIT_RREADY : n_state = rready_i ? WAIT_ARVALID: WAIT_RREADY ; 
            default     : n_state = WAIT_ARVALID;
        endcase
    end

    
    wire [31: 0] addr_reg_q;
    
    Reg # (32, 0) addr_reg (
        .clk (clk_i                ),
        .rst (rst                  ),
        .din (araddr_i             ),
        .dout(addr_reg_q           ),
        .wen (arvalid_i & arready_o)
    );
    

    assign arready_o = state == WAIT_ARVALID;
    assign rid_o     = awid_i               ;
    assign rresp_o   = 2'b00                ;
    assign rlast_o   = state == WAIT_RREADY ;
    assign rvalid_o  = state == WAIT_RREADY ;

    wire [63: 0] count_reg_q;
    Reg # (64, 0) count_reg (
        .clk (clk_i                ),
        .rst (rst                  ),
        .din (count_reg_q + 64'b1  ),
        .dout(count_reg_q          ),
        .wen (1'b1                 )
    );
    assign rdata_o = (addr_reg_q == 32'ha000_004C)? count_reg_q[63: 32]:  (addr_reg_q == 32'ha000_0048)?count_reg_q[31: 0]: 32'b0;
    
endmodule