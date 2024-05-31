module UART(
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
    wire rst = ~ rst_n_i;
    // ===========================================================================
    // state machine (just for write)
    /*
    parameter IDLE        = 4'b0001;
    parameter WAIT_WVALID = 4'b0010;
    parameter WAIT_WLAST  = 4'b0100;
    parameter WAIT_BREADY = 4'b1000;
    */


    //reg [ 3: 0] state, next_state;




    localparam IDLE        = 1'b0;
    localparam WAIT_BREADY = 1'b1;

    reg state, nstate;

    

    always @(posedge clk_i) begin
        if(rst) begin
            state <= IDLE      ;
        end
        else
            state <= nstate    ;
    end

    /*
    always @(*) begin
        case (state)
            IDLE       : next_state = awvalid_i? WAIT_WVALID                       : IDLE       ;
            WAIT_WVALID: next_state = wvalid_i ? (wlast_i? WAIT_BREADY: WAIT_WLAST): WAIT_WVALID;
            WAIT_WLAST : next_state = wlast_i  ? WAIT_BREADY                       : WAIT_WLAST ;
            WAIT_BREADY: next_state = bready_i ? IDLE                              : WAIT_BREADY;
            default    : next_state =                                                IDLE       ; 
        endcase
    end
    */
    always @(*) begin
        case(state)
            IDLE       : nstate = awvalid_i & wvalid_i? WAIT_BREADY: state;
            WAIT_BREADY: nstate = bready_i            ? IDLE       : state;
        endcase
    end

    assign awready_o =  (state == IDLE) & awvalid_i ;
    //assign wready_o  =  ((state == WAIT_WVALID) | (state == WAIT_WLAST)) & wvalid_i ;
    assign wready_o  =  (state == IDLE) & awvalid_i ;
    assign bid_o     = awid_i                                                       ;
    assign bresp_o   = 2'b00                                                        ;
    assign bvalid_o  = (state == WAIT_BREADY)                                       ;

    always @(posedge clk_i) begin
        if(nstate == WAIT_BREADY) begin
            $write("%c", wdata_i[ 7: 0]);
        end
    end


endmodule