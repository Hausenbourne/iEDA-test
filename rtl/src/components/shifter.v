module shifter(
    input  [31:0] Din,
    input  [4:0]Shamt,
    input  L_R,
    input  A_L,
    output [31:0]Dout
);
    wire [63:0] sra_intern;
    assign      sra_intern = {{32{Din[31]}},Din} >> Shamt;
    assign      Dout       = A_L?(L_R?(Din << Shamt):sra_intern[31:0]):(L_R?(Din << Shamt):(Din >> Shamt));

endmodule