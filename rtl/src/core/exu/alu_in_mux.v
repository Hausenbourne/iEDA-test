module alu_in_mux(
    input  [31:0]pc,
    input  [31:0]src1,
    input  [31:0]src2,
    input  [31:0]imm,

    input        ALUAsrc,
    input  [ 1:0]ALUBsrc,

    output [31:0]A,
    output [31:0]B
);
    assign A = ALUAsrc?pc:src1;

    MuxKey #(4, 2, 32) ALUBsrc_MUX (B, ALUBsrc,{
        2'b00, src2,
        2'b01, imm,
        2'b10, 32'b100,
        2'b11, src2
    });

endmodule