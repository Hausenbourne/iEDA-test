module ImmGen(
    input  [31:0] inst,
    input  [ 2:0] ext_opt,
    output [31:0] imm
);

    wire [31:0]immI = {{20{inst[31]}}, inst[31:20]};
    wire [31:0]immU = {inst[31:12], 12'b0};
    wire [31:0]immS = {{20{inst[31]}},inst[31:25],inst[11:7]};
    wire [31:0]immB = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
    wire [31:0]immJ = {{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};



    MuxKeyWithDefault #(5, 3, 32) ImmGen_MUX (imm, ext_opt, immI, {
        3'b000, immI,
        3'b001, immU,
        3'b010, immS,
        3'b011, immB,
        3'b100, immJ
    });


endmodule

//参考：https://nju-projectn.github.io/dlco-lecture-note/exp/11.html#tab-extop