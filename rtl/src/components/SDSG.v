module SDSG #(DEPTH = 256, RESET_VAL = 0)(
    input          clk_i      ,
    input          rst_i      ,
    input [ 7: 0]  delay_num_i,
    input          signal_i   ,
    output         signal_o
);

    reg [DEPTH - 1:0] register;
    always @(posedge clk_i) begin
        if (rst_i) begin
            register <= RESET_VAL;
        end 
        else begin
            register <= {register[DEPTH-2:0], signal_i};
        end
    end

    assign signal_o = register[delay_num_i];//0~DEPTH-1

endmodule
