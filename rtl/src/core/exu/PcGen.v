module PcGen(
    input  [31:0]imm,
    input  [31:0]pc,
    input  [31:0]src1,
    input        PCAsrc,
    input        PCBsrc,
    output [31:0]next_pc
);

    wire [31:0]A;
    wire [31:0]B;

    assign A = PCAsrc?imm:32'd4;
    assign B = PCBsrc?src1:pc;

    assign next_pc = A + B;

endmodule

//参考：https://nju-projectn.github.io/dlco-lecture-note/exp/11.html#tab-extop