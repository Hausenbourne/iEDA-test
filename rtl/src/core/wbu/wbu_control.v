module wbu_control(
    input  i_clk,
    input  i_rst_n,

    input  i_reg_wena,
    output o_reg_wena,

    output o_csr_ena,

    output o_done,
    //Handshake signal
    input  i_valid,
    output o_ready
);

    /**********************/   
    reg state, nstate;

    parameter IDLE         = 1'b0;
    parameter WRITTEN_BACK = 1'b1;

    always @(posedge i_clk) begin
        if(~i_rst_n)
            state <= IDLE  ;
        else
            state <= nstate;                
    end

    always @(*) begin
        case(state)
            IDLE        : nstate = i_valid? WRITTEN_BACK: IDLE;
            WRITTEN_BACK: nstate = IDLE                       ;
            default     : nstate = IDLE                       ;
        endcase
    end
    
    assign o_reg_wena = state == IDLE & i_valid & i_reg_wena;
    assign o_csr_ena  = state == IDLE & i_valid             ; 
    assign o_ready    = state == IDLE                       ;
    //assign o_free     = state == IDLE & ~i_valid            ;
    
    assign o_done     = state == WRITTEN_BACK               ;//这个具体可以根据不同的指令来修改

    /**********************/
    `ifdef SIMULATION
    `ifdef CONFIG_PERF
    import "DPI-C" function void PREF_COUNT(input int ev);
    always@(posedge i_clk) begin
        if(i_rst_n) begin
            if(state == IDLE) begin
                PREF_COUNT(`WBU_WAIT);
            end
    
            else if(state == WRITTEN_BACK) begin
                PREF_COUNT(`WBU_TRANS);
            end
        end
    end
    `endif
    `endif

    `ifdef SIMULATION
    import "DPI-C" function void WBU_TRACE();
    always @(posedge i_clk) begin
        if(o_done) begin
            WBU_TRACE();
        end
    end
    `endif

endmodule