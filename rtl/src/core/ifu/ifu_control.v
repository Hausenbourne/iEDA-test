//`define CONFIG_IFU_RDG     1
module ifu_control(
    input              clk_i    ,
    input              rst_n_i  ,
    //from or to PC
    input      [31: 0] pc_i     ,
    output             ena_o    ,
    //to IDU
    output     [31: 0] inst_o   ,
    output             valid_o  ,
    input              ready_i  ,
    //from WBU
    input              done_i   ,
    //axi interface
    output     [ 3: 0] arid_o   ,
    output     [31: 0] araddr_o ,
    output     [ 7: 0] arlen_o  ,
    output     [ 2: 0] arsize_o ,
    output     [ 1: 0] arburst_o,
    output             arvalid_o,
    input              arready_i,
    
    input      [ 3: 0] rid_i    ,
    input      [31: 0] rdata_i  ,
    input      [ 1: 0] rresp_i  ,
    input              rlast_i  ,
    input              rvalid_i ,
    output             rready_o 
);
    wire rst      = ~rst_n_i            ;  
    wire raddr_ok = arvalid_o& arready_i;
    wire read_ok  = rready_o & rvalid_i ;
    // ===========================================================================
    //state machine

    localparam IDLE          = 4'b0000     ;
    localparam FIRST_UP_PC   = 4'b0001     ;
    localparam WAIT_RREQUEST = 4'b0010     ;
    localparam WAIT_ARREADY  = 4'b0011     ;
    localparam WAIT_RVALID   = 4'b0100     ;
    localparam WAIT_READY    = 4'b0101     ;


    reg [ 3: 0] state, next_state;

    always @(posedge clk_i) begin
        if(rst)begin
            //state <= WAIT_ARREADY;
            state <= IDLE;
        end
        else begin
            state <= next_state ;
        end
    end
 

    always @(*) begin
        case(state)
            IDLE         : next_state = FIRST_UP_PC                           ;
            FIRST_UP_PC  : next_state = WAIT_ARREADY                          ;
            WAIT_RREQUEST: next_state = done_i  ? WAIT_ARREADY : WAIT_RREQUEST;
            WAIT_ARREADY : next_state = raddr_ok? WAIT_RVALID  : WAIT_ARREADY ; 
            WAIT_RVALID  : next_state = read_ok ? WAIT_READY   : WAIT_RVALID  ;
            WAIT_READY   : next_state = ready_i ? WAIT_RREQUEST: WAIT_READY   ;
            default      : next_state =                          IDLE;
        endcase
    end


    // ===========================================================================
    //to PC
    //assign ena_o     = (state == WAIT_READY  )& ready_i                           ;

    assign ena_o     = state == FIRST_UP_PC | done_i;
    // ===========================================================================
    //axi interface
    assign arid_o    = 4'b0                                                       ;//ignore
    assign araddr_o  = (state == WAIT_ARREADY)? pc_i : 32'b0                      ;
    assign arlen_o   = 8'b0                                                       ;//ignore
    assign arsize_o  = 3'b010                                                     ;//32bit
    assign arburst_o = 2'b01                                                      ;//increment 
    wire   arvalid   = state == WAIT_ARREADY                                      ;
    wire   rready    = (state == WAIT_RVALID) & rvalid_i                          ;

    `ifdef CONFIG_IFU_RDG
    wire [31: 0] random;
    RDG  RDG_inst (
        .clk_i      (clk_i                        ),
        .rst_n_i    (rst_n_i                      ),
        .random_o   (random                       )
    );
    
    SDSG arvalid_SDSG_inst (
        .clk_i      (clk_i                        ),
        .rst_i      (rst | (arvalid_o & arready_i)),
        .delay_num_i(random[ 7: 0]                ),
        .signal_i   (arvalid                      ),
        .signal_o   (arvalid_o                    )
    );

    SDSG rready_SDSG_inst (
        .clk_i      (clk_i        ),
        .rst_i      (rst | (rready_o & rvalid_i)  ),
        .delay_num_i(random[ 8: 1]                ),
        .signal_i   (rready                       ),
        .signal_o   (rready_o                     )
    );

    `else
    assign arvalid_o = arvalid;
    assign rready_o  = rready ;
    `endif

    // ===========================================================================
    //to IDU
    assign valid_o = (state == WAIT_READY)                             ;
    wire   inst_en = (rvalid_i & rready_o)                             ;//////
    Reg # (32, 0) inst_reg_inst (clk_i, rst, rdata_i, inst_o, inst_en) ;

    // ===========================================================================
    // ifu error
    `ifdef SIMULATION
    wire ifu_error  = ( state == WAIT_RVALID ) & read_ok & (rresp_i == 2'b10 | rresp_i == 2'b11);
    always @(*) begin
        if (ifu_error == 1'b1) begin 
            $display("ifu error");
            $finish              ; 
        end
    end
    `endif
    
    // ===========================================================================
    // 

    `ifdef SIMULATION
    `ifdef CONFIG_PERF
    import "DPI-C" function void PREF_COUNT(input int ev);
    always@(posedge clk_i) begin
        if(rvalid_i & rready_o) begin
            PREF_COUNT(`INS_FETCH);
        end

        if(~rst & state == WAIT_RREQUEST) begin
            PREF_COUNT(`IFU_WAIT);
        end

        if(state == WAIT_ARREADY | state == WAIT_RVALID) begin
            PREF_COUNT(`IFU_DELAY);
        end

        if(state == WAIT_READY) begin
            PREF_COUNT(`IFU_TRANS);
        end
  
        if(~rst) begin
            PREF_COUNT(`CYCLE);
        end 
    end
    `endif
    `endif

    `ifdef SIMULATION
    import "DPI-C" function void IFU_TRACE(input int pc, input int ins);
    always @(posedge clk_i) begin
        if(read_ok) begin
            IFU_TRACE(pc_i, inst_o);
        end
    end
    `endif
    

endmodule