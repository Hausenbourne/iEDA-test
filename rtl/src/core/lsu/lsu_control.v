//`define CONFIG_LSU_RDG     1

module lsu_control(
    input          clk_i      ,
    input          rst_n_i    ,
    //from EXU
    input          MemWr_i    ,
    input  [ 2: 0] MemOp_i    ,
    input          MemRe_i    ,
    input  [31: 0] addr_i     ,
    input  [31: 0] wdata_i    ,
    input          valid_i    ,
    output         ready_o    ,

    //axi interface
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
    output         bready_o   ,

    //to WBU
    output [31: 0] mem_rdata_o,
    output         valid_o    ,
    input          ready_i

);
    wire        rst      =          ~ rst_n_i  ;
    wire        raddr_ok = arvalid_o& arready_i;
    wire        waddr_ok = awvalid_o& awready_i;
    wire        read_ok  = rready_o & rvalid_i ;
    wire        write_ok = wvalid_o & wready_i ;
    wire        wb_ok    = bready_o & bvalid_i ;

    wire [ 7: 0] bdata   = wdata_i[ 7: 0]      ;
    wire [15: 0] hdata   = wdata_i[15: 0]      ;
    wire [31: 0] wdata   = wdata_i[31: 0]      ;

    wire         sb_000  = MemOp_i == 3'b000   ;
    wire         sh_001  = MemOp_i == 3'b001   ;
    wire         sw_010  = MemOp_i == 3'b010   ;

    wire         lb_000  = MemOp_i == 3'b000   ;
    wire         lh_001  = MemOp_i == 3'b001   ;
    wire         lw_010  = MemOp_i == 3'b010   ;
    wire         lbu_100 = MemOp_i == 3'b100   ;
    wire         lhu_101 = MemOp_i == 3'b101   ;

    wire [ 1: 0] offset  = addr_i[ 1: 0]       ;

    wire offset_0        = offset == 2'b00     ;
    wire offset_1        = offset == 2'b01     ; 
    wire offset_2        = offset == 2'b10     ;
    wire offset_3        = offset == 2'b11     ;  
    // ===========================================================================
    //state machine
    parameter WAIT_VALID   = 9'b000000001   ;
    parameter WAIT_ARREADY = 9'b000000010   ;
    parameter WAIT_RLAST   = 9'b000000100   ;
    parameter WAIT_RVALID  = 9'b000001000   ;
    parameter WAIT_READY   = 9'b000010000   ;

    parameter ADDR_DATA_TRANS = 9'b000100000;
    parameter WAIT_BRESP      = 9'b001000000;
    parameter DATA_TRANS      = 9'b010000000;
    parameter ADDR_TRANS      = 9'b100000000;

    reg [ 8: 0] state, next_state;

    always @(posedge clk_i) begin
        if(rst) begin
            state <= WAIT_VALID;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            WAIT_VALID     : next_state = valid_i ? (MemRe_i? WAIT_ARREADY: MemWr_i? ADDR_DATA_TRANS: WAIT_READY): WAIT_VALID  ;
            WAIT_ARREADY   : next_state = raddr_ok? WAIT_RLAST                                                   : WAIT_ARREADY;
            WAIT_RLAST     : next_state = read_ok ? (rlast_i? WAIT_READY  : WAIT_RLAST)                          : WAIT_RVALID ;
            WAIT_RVALID    : next_state = read_ok ? (rlast_i? WAIT_READY  : WAIT_RLAST)                          : WAIT_RVALID ;
            WAIT_READY     : next_state = ready_i ? WAIT_VALID                                                   : WAIT_READY  ;
            
            ADDR_DATA_TRANS: next_state = (waddr_ok & write_ok & wlast_o)? WAIT_BRESP: 
                                          (waddr_ok & ~wlast_o          )? DATA_TRANS: 
                                          (write_ok & wlast_o           )? ADDR_TRANS: 
                                          ADDR_DATA_TRANS                            ;

            WAIT_BRESP     : next_state = wb_ok                          ? WAIT_READY                            : WAIT_BRESP  ;     
            DATA_TRANS     : next_state = (write_ok & wlast_o           )? WAIT_BRESP                            : DATA_TRANS  ;
            ADDR_TRANS     : next_state = waddr_ok                       ? WAIT_BRESP                            : ADDR_TRANS  ;
            default        : next_state = WAIT_VALID                                                                           ;
        endcase
    end

    //output
    assign ready_o = state == WAIT_VALID;
    assign valid_o = state == WAIT_READY                                                                ;
    wire   arvalid =   state == WAIT_ARREADY                                                            ;
    wire   rready  = ((state == WAIT_RLAST)  | (state == WAIT_RVALID)) & rvalid_i                       ;
    wire   awvalid = (state == ADDR_DATA_TRANS) | (state == ADDR_TRANS)                                 ;
    wire   wvalid  = (state == ADDR_DATA_TRANS) | (state == DATA_TRANS)                                 ;
    wire   bready  = (state == WAIT_BRESP     ) & bvalid_i                                              ; 



    `ifdef CONFIG_LSU_RDG
    wire [31: 0] random;
    RDG  RDG_inst (
        .clk_i      (clk_i         ),
        .rst_n_i    (rst_n_i       ),
        .random_o   (random        )
    );
    
    SDSG arvalid_SDSG_inst (
        .clk_i      (clk_i         ),
        .rst_i      (rst | raddr_ok),
        .delay_num_i(random[ 9: 2] ),
        .signal_i   (arvalid       ),
        .signal_o   (arvalid_o     )
    );

    SDSG rready_SDSG_inst (
        .clk_i      (clk_i         ),
        .rst_i      (rst | read_ok ),
        .delay_num_i(random[10: 3] ),
        .signal_i   (rready        ),
        .signal_o   (rready_o      )
    );

    SDSG awvalid_SDSG_inst (
        .clk_i      (clk_i         ),
        .rst_i      (rst | waddr_ok),
        .delay_num_i(random[11: 4] ),
        .signal_i   (awvalid       ),
        .signal_o   (awvalid_o     )
    );
    
    SDSG wvalid_SDSG_inst (
        .clk_i      (clk_i          ),
        .rst_i      (rst | write_ok ),
        .delay_num_i(random[12: 5]  ),
        .signal_i   (wvalid         ),
        .signal_o   (wvalid_o       )
    );

    SDSG bready_SDSG_inst (
        .clk_i      (clk_i          ),
        .rst_i      (rst | wb_ok    ),
        .delay_num_i(random[13: 6]  ),
        .signal_i   (bready         ),
        .signal_o   (bready_o       )
    );
    `else
    assign arvalid_o = arvalid;
    assign rready_o  = rready ;
    assign awvalid_o = awvalid;
    assign wvalid_o  = wvalid ;
    assign bready_o  = bready ;
    `endif
    // ===========================================================================
    // axi interface

    wire [31: 0] addr;
    Reg # (32, 32'h30000000) addr_reg_inst (clk_i, rst, addr_i, addr, valid_i & ready_o);

    assign arid_o   = 4'b0    ;
    assign araddr_o = addr;
    assign arlen_o  = 8'b0    ;
    assign arsize_o = (lb_000 | lbu_100)? 3'b000:
                      (lh_001 | lhu_101)? 3'b001: 
                      3'b010;

    assign arburst_o= 2'b01   ;
    
    assign awid_o   = 4'b0    ;
    assign awaddr_o = addr;
    assign awlen_o  = 8'b0    ;

    assign awsize_o = MemOp_i ;
    assign awburst_o= 2'b01   ;

    assign wid_o    = 4'b0    ;

   

    assign wdata_o  = {32{sb_000 & offset_0}} & {24'b0, bdata       }
       |              {32{sb_000 & offset_1}} & {16'b0, bdata,  8'b0}
       |              {32{sb_000 & offset_2}} & { 8'b0, bdata, 16'b0}
       |              {32{sb_000 & offset_3}} & {       bdata, 24'b0}
       |              {32{sh_001 & offset_0}} & {16'b0, hdata       }
       |              {32{sh_001 & offset_1}} & { 8'b0, hdata,  8'b0}
       |              {32{sh_001 & offset_2}} & {       hdata, 16'b0}
       |              {32{sw_010 & offset_0}} & {       wdata       };

    
    assign wstrb_o  = {4{sb_000 & offset_0}} & 4'b0001
       |              {4{sb_000 & offset_1}} & 4'b0010
       |              {4{sb_000 & offset_2}} & 4'b0100
       |              {4{sb_000 & offset_3}} & 4'b1000
       |              {4{sh_001 & offset_0}} & 4'b0011
       |              {4{sh_001 & offset_1}} & 4'b0110
       |              {4{sh_001 & offset_2}} & 4'b1100
       |              {4{sw_010 & offset_0}} & 4'b1111;
    

    assign wlast_o  = wvalid_o; 
    // ===========================================================================
    // to WBU
    wire [31: 0] unalign_src = {32{ lb_000}} & {{24{rdata_i[ 7]}},rdata_i[ 7: 0]}           
    |                          {32{ lh_001}} & {{16{rdata_i[15]}},rdata_i[15: 0]}
    |                          {32{ lw_010}} &                    rdata_i
    |                          {32{lbu_100}} & {24'b0            ,rdata_i[ 7: 0]}
    |                          {32{lhu_101}} & {16'b0            ,rdata_i[15: 0]};

    wire [31: 0] align_src   = {32{ lb_000 & offset_0}} & {{24{rdata_i[ 7]}},rdata_i[ 7: 0]}
    |                          {32{ lb_000 & offset_1}} & {{24{rdata_i[15]}},rdata_i[15: 8]}
    |                          {32{ lb_000 & offset_2}} & {{24{rdata_i[23]}},rdata_i[23:16]}
    |                          {32{ lb_000 & offset_3}} & {{24{rdata_i[31]}},rdata_i[31:24]}              
    |                          {32{ lh_001 & offset_0}} & {{16{rdata_i[15]}},rdata_i[15: 0]}
    |                          {32{ lh_001 & offset_1}} & {{16{rdata_i[23]}},rdata_i[23: 8]}
    |                          {32{ lh_001 & offset_2}} & {{16{rdata_i[31]}},rdata_i[31:16]}
    |                          {32{ lw_010 & offset_0}} &                    rdata_i
    |                          {32{lbu_100 & offset_0}} & {24'b0            ,rdata_i[ 7: 0]}
    |                          {32{lbu_100 & offset_1}} & {24'b0            ,rdata_i[15: 8]}
    |                          {32{lbu_100 & offset_2}} & {24'b0            ,rdata_i[23:16]}
    |                          {32{lbu_100 & offset_3}} & {24'b0            ,rdata_i[31:24]}           
    |                          {32{lhu_101 & offset_0}} & {16'b0            ,rdata_i[15: 0]}
    |                          {32{lhu_101 & offset_1}} & {16'b0            ,rdata_i[23: 8]}
    |                          {32{lhu_101 & offset_2}} & {16'b0            ,rdata_i[31:16]};
    
    wire is_uart = (addr_i >= 32'h10000000) && (addr_i <= 32'h10000fff);

    wire stb_reg_c = clk_i   ;
    wire stb_reg_r = rst     ;
    wire stb_reg_d = is_uart ;
    wire stb_reg_q           ;
    wire stb_reg_e = raddr_ok;

    Reg # (1, 0) stb_reg (
        .clk (stb_reg_c ),
        .rst (stb_reg_r ),
        .din (stb_reg_d ),
        .dout(stb_reg_q ),
        .wen (stb_reg_e )
    );


    wire         data_reg_c = clk_i                                                        ;
    wire         data_reg_r = rst                                                          ;
        
    wire [31: 0] data_reg_d = stb_reg_q? unalign_src: align_src                            ;
    wire [31: 0] data_reg_q                                                                ;
    wire         data_reg_e = (next_state == WAIT_READY)                                   ;

    Reg # (32, 0) data_reg (
        .clk (data_reg_c ),
        .rst (data_reg_r ),
        .din (data_reg_d ),
        .dout(data_reg_q ),
        .wen (data_reg_e )
    );

    assign      mem_rdata_o = data_reg_q                                                    ;

    // ===========================================================================
    // lsu error
    wire lsu_error = ( state == WAIT_RLAST ) & read_ok & (rresp_i == 2'b10 | rresp_i == 2'b11)|
                     ( state == WAIT_BRESP ) & wb_ok   & (bresp_i == 2'b10 | bresp_i == 2'b11);
    `ifdef SIMULATION
    always @(*) begin
        if (lsu_error == 1'b1) begin 
            $display("lsu error");
            $finish              ; 
        end
    end
    `endif 
    // ===========================================================================
    // lsu trace
    `ifdef SIMULATION
    `ifdef CONFIG_PERF
    import "DPI-C" function void PREF_COUNT(input int ev);
    always@(posedge clk_i) begin

        if (~rst) begin
            if(state == WAIT_VALID) begin
                PREF_COUNT(`LSU_WAIT);
            end
    
            if(state != WAIT_READY & state != WAIT_VALID & MemRe_i) begin
                PREF_COUNT(`LSU_LOAD_DELAY);
            end
    
            if(state != WAIT_READY & state != WAIT_VALID & MemWr_i) begin
                PREF_COUNT(`LSU_STORE_DELAY);
            end
    
            if(state == WAIT_READY) begin
                PREF_COUNT(`LSU_TRANS);
            end
        end
    end
    `endif
    `endif
endmodule