//`include "/home/bourne/ysyx-workbench/npc/vsrc/components/adder.v"
//`include "/home/bourne/ysyx-workbench/npc/vsrc/components/mux.v"
//`include "/home/bourne/ysyx-workbench/npc/vsrc/components/shifter.v"

module ALU(
    input  [31:0]  A,
    input  [31:0]  B,
    input  [3: 0]  ALUctr,
    output [31: 0] ALUout,
    output         Less,
    output         Zero
);
    
    //控制信号
    wire        SUBctr;//
    wire        SIGctr;//
    wire        DIRctr;//移位方向
    wire        ARIctr;//移位模式

    assign ARIctr =  ALUctr[3] &  ALUctr[2] & ~ALUctr[1] &  ALUctr[0];
    assign DIRctr = ~ALUctr[2] & ~ALUctr[1] &  ALUctr[0];
    assign SIGctr = ~ALUctr[3] & ~ALUctr[2] &  ALUctr[1] & ~ALUctr[0];
    assign SUBctr =  ALUctr[3] & ~ALUctr[2] & ~ALUctr[1] & ~ALUctr[0] | ~ALUctr[2] & ALUctr[1] & ~ALUctr[0];

    //控制器
    //alu输出通路信号
    wire [31:0] adder;
    wire [31:0] shift;
    wire [31:0] slt;
    wire [31:0] XOR;
    wire [31:0] OR;
    wire [31:0] AND;

    //中间信号
    wire        Carry;
    wire        Overflow;

    Adder  Adder_inst (
        .A(A),
        .B(B),
        .Cin(SUBctr),
        .Carry(Carry),
        .Zero(Zero),
        .Overflow(Overflow),
        .Result(adder)
    );

    shifter  shifter_inst (
        .Din(A),
        .Shamt(B[4:0]),
        .L_R(DIRctr),
        .A_L(ARIctr),
        .Dout(shift)
  );

  assign slt = {{31{1'b0}},Less};
  assign XOR = A ^ B;
  assign OR  = A | B;
  assign AND = A & B;

    MuxKey #(8, 3, 32) Alu_MUX (ALUout, ALUctr[2:0], {
        3'b000, adder,
        3'b001, shift,
        3'b010, slt,
        3'b011, B,
        3'b100, XOR,
        3'b101, shift,
        3'b110, OR,
        3'b111, AND
    });

    assign Less = SIGctr?(Overflow ^ adder[31]):(Carry ^ SUBctr);

endmodule

//参考：https://nju-projectn.github.io/dlco-lecture-note/exp/10.html