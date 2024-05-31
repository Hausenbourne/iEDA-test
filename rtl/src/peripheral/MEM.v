//`define CONFIG_SRAM_RDG    1
module MEM(
    input              clk_i    ,
    input              rst_n_i  ,
    //axi interface
    input      [ 3: 0] arid_i   ,
    input      [31: 0] araddr_i ,
    input      [ 7: 0] arlen_i  ,
    input      [ 2: 0] arsize_i ,
    input      [ 1: 0] arburst_i,
    input              arvalid_i,
    output             arready_o,
    
    output     [ 3: 0] rid_o    ,
    output     [31: 0] rdata_o  ,
    output     [ 1: 0] rresp_o  ,
    output             rlast_o  ,
    output             rvalid_o ,
    input              rready_i ,

    input      [ 3: 0] awid_i   ,
    input      [31: 0] awaddr_i ,
    input      [ 7: 0] awlen_i  ,
    input      [ 2: 0] awsize_i ,
    input      [ 1: 0] awburst_i,
    input              awvalid_i,
    output             awready_o,

    input      [ 3: 0] wid_i    ,
    input      [31: 0] wdata_i  ,
    input      [ 3: 0] wstrb_i  ,
    input              wlast_i  ,
    input              wvalid_i ,
    output             wready_o ,

    output     [ 3: 0] bid_o    ,
    output     [ 1: 0] bresp_o  ,
    output             bvalid_o ,
    input              bready_i
);

    
    // ===========================================================================
    // basic signal 
    wire               rst =          ~rst_n_i ; 
     
    wire         ar_ok     = arvalid_i& arready_o;////
    wire         r_ok      = rready_i & rvalid_o ;////
    wire         aw_ok     = awvalid_i& awready_o;////
    wire         w_ok      = wvalid_i & wready_o ;////
    wire         b_ok      = bvalid_o & bready_i ;

    wire         addr_ok   = rw_reg_d? aw_ok   : ar_ok   ;
    wire         data_ok   = rw_reg_q? w_ok    : r_ok    ;
    wire [31: 0] addr      = rw_reg_d? awaddr_i: araddr_i;
    wire [ 2: 0] axsize    = rw_reg_d? awsize_i: arsize_i;
    wire         last      = rw_reg_q? wlast_i : rlast_o ;

    wire [31: 0] axsize_dec= 1 << axsize;
    
    // ===========================================================================
    //  state machine
    parameter IDLE        = 5'b00001;
    parameter WAIT_RREADY = 5'b00010; 
    parameter WAIT_RLAST  = 5'b00100;
    parameter WAIT_WLAST  = 5'b01000;
    parameter WAIT_BREADY = 5'b10000;

    reg [ 4: 0] state, nstate;

    always @(posedge clk_i) begin
        if(rst) begin
            state <= IDLE  ;
        end
        else begin
            state <= nstate;
        end
    end

    always @(*) begin
        case(state)
            IDLE       : nstate = ar_ok  ?  WAIT_RREADY: (aw_ok? (wlast_i? WAIT_BREADY: WAIT_WLAST): IDLE);
            WAIT_RREADY: nstate = r_ok   ? (rlast_o? IDLE: WAIT_RLAST): WAIT_RREADY; 
            WAIT_RLAST : nstate = rlast_o?                        IDLE: WAIT_RLAST ;
            WAIT_WLAST : nstate = wlast_i?                 WAIT_BREADY: WAIT_WLAST ;
            WAIT_BREADY: nstate = b_ok   ?                        IDLE: WAIT_BREADY;
            default    : nstate = IDLE                                             ;
        endcase
    end


    wire arready = state == IDLE              & arvalid_i                       ;
    wire rvalid  = state == WAIT_RREADY       | state == WAIT_RLAST             ;
    wire awready = state == IDLE              & awvalid_i                       ;
    wire wready  = (state == IDLE & wvalid_i) | (state == WAIT_WLAST & wvalid_i);
    wire bvalid  = state == WAIT_BREADY                                         ;

    `ifdef CONFIG_SRAM_RDG
    wire [31: 0] random;
    RDG  RDG_inst (
        .clk_i      (clk_i         ),
        .rst_n_i    (rst_n_i       ),
        .random_o   (random        )
    );

    SDSG arready_SDSG_inst (
        .clk_i      (clk_i         ),
        .rst_i      (rst |    ar_ok),
        .delay_num_i(random[14: 7] ),
        .signal_i   (arready       ),
        .signal_o   (arready_o     )
    );

    SDSG rvalid_SDSG_inst (
        .clk_i      (clk_i          ),
        .rst_i      (rst |    r_ok  ),
        .delay_num_i(random[15: 8]  ),
        .signal_i   (rvalid         ),
        .signal_o   (rvalid_o       )
    );

    SDSG awready_SDSG_inst (
        .clk_i      (clk_i          ),
        .rst_i      (rst | aw_ok    ),
        .delay_num_i(random[16: 9]  ),
        .signal_i   (awready        ),
        .signal_o   (awready_o      )
    );

    SDSG wready_SDSG_inst (
        .clk_i      (clk_i          ),
        .rst_i      (rst | w_ok     ),
        .delay_num_i(random[17:10]  ),
        .signal_i   (wready         ),
        .signal_o   (wready_o       )
    );

    SDSG bvalid_SDSG_inst (
        .clk_i      (clk_i          ),
        .rst_i      (rst |  b_ok    ),
        .delay_num_i(random[18:11]  ),
        .signal_i   (bvalid         ),
        .signal_o   (bvalid_o       )
    );
    `else
    assign arready_o = arready;
    assign rvalid_o  = rvalid ;
    assign awready_o = awready;
    assign wready_o  = wready ;
    assign bvalid_o  = bvalid ;
    `endif
    // ===========================================================================
    //  Reading and writing channel selection signal
    wire rw_reg_c = clk_i                         ;
    wire rw_reg_r = rst                           ;
    wire rw_reg_d = aw_ok| ~arvalid_i | ~arready_o;//////
    wire rw_reg_q                                 ;
    wire rw_reg_e = ar_ok| aw_ok                  ;

    Reg # (1, 0) rw_reg (
        .clk (rw_reg_c ),
        .rst (rw_reg_r ),
        .din (rw_reg_d ),
        .dout(rw_reg_q ),
        .wen (rw_reg_e )
    );
    // ===========================================================================
    //  read and write circuit

    // addr_reg
    wire         addr_reg_c = clk_i            ;
    wire         addr_reg_r = rst              ;
    wire [31: 0] addr_reg_d = addr + axsize_dec;
    wire [31: 0] addr_reg_q                    ;
    wire         addr_reg_e = addr_ok          ;
    
    Reg # (32, 0) addr_reg (
        .clk (addr_reg_c ),
        .rst (addr_reg_r ),
        .din (addr_reg_d ),
        .dout(addr_reg_q ),
        .wen (addr_reg_e )
    );


    // axsize_reg
    wire         axsize_reg_c = clk_i         ;
    wire         axsize_reg_r = last     | rst;
    wire [31: 0] axsize_reg_d = axsize_dec    ;
    wire [31: 0] axsize_reg_q                 ;
    wire         axsize_reg_e = addr_ok       ; 

    Reg # (32, 0) axsize_reg (
        .clk (axsize_reg_c),
        .rst (axsize_reg_r),
        .din (axsize_reg_d),
        .dout(axsize_reg_q),
        .wen (axsize_reg_e)
    );

    // offset_reg
    wire         offset_reg_c = clk_i                      ;
    wire         offset_reg_r = last         | rst         ;
    wire [31: 0] offset_reg_d = axsize_reg_q + offset_reg_q;
    wire [31: 0] offset_reg_q                              ;
    wire         offset_reg_e = data_ok                    ;

    Reg # (32, 0) offset_reg (
        .clk (offset_reg_c),
        .rst (offset_reg_r),
        .din (offset_reg_d),
        .dout(offset_reg_q),
        .wen (offset_reg_e)
    );

    //  SPRAM
    wire [31: 0] spram_addr = addr_ok? addr: addr_reg_q + offset_reg_q;
    spram  spram_inst (
        .clk_i  (clk_i            ),
        .addr_i (spram_addr       ),
        .data_i (wdata_i          ),
        .wmask_i(wstrb_i          ),
        .ena_i  ((ar_ok | (r_ok & ~rlast_o))|w_ok),
        .wen_i  (w_ok    ),
        .data_o (rdata_o )
    );

    // ===========================================================================
    // Rlast signal circuit
    wire         arlen_reg_c = clk_i  ;
    wire         arlen_reg_r = rst    ;
    wire [ 7: 0] arlen_reg_d = arlen_i;
    wire [ 7: 0] arlen_reg_q          ;
    wire         arlen_reg_e = ar_ok  ;

    Reg # (8, 0) arlen_reg (
        .clk (arlen_reg_c),
        .rst (arlen_reg_r),
        .din (arlen_reg_d),
        .dout(arlen_reg_q),
        .wen (arlen_reg_e)
    );

    wire [ 7: 0] arlen = ar_ok? arlen_i: arlen_reg_q;

    wire         count_reg_c = clk_i                   ;
    wire         count_reg_r = rst  | (r_ok & rlast_o) ;
    wire [ 7: 0] count_reg_d = count_reg_q + 1'b1      ;
    wire [ 7: 0] count_reg_q                           ;
    wire         count_reg_e = r_ok                    ;

    Reg # (8, 0) count_reg (
        .clk (count_reg_c),
        .rst (count_reg_r),
        .din (count_reg_d),
        .dout(count_reg_q),
        .wen (count_reg_e)
    );

    assign rlast_o = count_reg_q == arlen;
    // ===========================================================================
    // ignore output
    assign rid_o   = arid_i;
    assign rresp_o = 2'b00 ;
    assign bid_o   = awid_i;
    assign bresp_o = 2'b00 ;

endmodule
