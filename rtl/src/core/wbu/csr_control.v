module csr_control(
    input  [31:0] i_pc,
    input  [31:0] i_imm,
    input  [31:0] i_src1,
    input  [31:0] i_inst,
    input  [31:0] i_csr_src,
    input         i_ena,

    output [31:0] o_wdata1,
    output [11:0] o_waddr1,
    output        o_wena1,

    output [31:0] o_wdata2,
    output [11:0] o_waddr2,
    output        o_wena2,

    output [11:0] o_raddr
);
    wire[ 6:0]  opcode      = i_inst[ 6: 0];
    wire [2:0]  rv32_func3  = i_inst[14:12];

    wire opcode_6_5_11  = (opcode[6:5] == 2'b11);
    wire opcode_4_2_100 = (opcode[4:2] == 3'b100);
    wire opcode_1_0_11  = (opcode[1:0] == 2'b11);
    wire rv32_system   = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11;

    wire rv32_func3_000 = (rv32_func3 == 3'b000);
    wire rv32_func3_001 = (rv32_func3 == 3'b001);
    wire rv32_func3_010 = (rv32_func3 == 3'b010);
    wire rv32_func3_101 = (rv32_func3 == 3'b101);
    wire rv32_func3_110 = (rv32_func3 == 3'b110);

    wire rv32_ecall    = rv32_system & rv32_func3_000 & (i_inst[31:20] == 12'b0000_0000_0000);
    wire rv32_mret     = rv32_system & rv32_func3_000 & (i_inst[31:20] == 12'b0011_0000_0010);

    wire rv32_csrrw    = rv32_system & rv32_func3_001; 
    wire rv32_csrrs    = rv32_system & rv32_func3_010;
    wire rv32_csrrwi   = rv32_system & rv32_func3_101; 
    wire rv32_csrrsi   = rv32_system & rv32_func3_110; 

	// ===========================================================================
    wire [2:0] csr_sel = 
          {3{rv32_ecall }} & 3'b000      //若当前为ecall指令则为 A
        | {3{rv32_csrrw }} & 3'b001		 //若当前为csrrw指令则为 C
        | {3{rv32_csrrs }} & 3'b010      //若当前为csrrs指令则为 C | D
        | {3{rv32_csrrwi}} & 3'b011      //若当前为csrrwi指令则为B
        | {3{rv32_csrrsi}} & 3'b100;     //若当前为csrrsi指令则为B | D
    
    MuxKeyWithDefault # (5, 3, 32) mux(o_wdata1, csr_sel, 32'b0, {
        3'b000, i_pc,
        3'b001, i_src1,
        3'b010, i_src1 | i_csr_src,
        3'b011, i_imm,
        3'b100, i_imm | i_csr_src
    });

    assign o_waddr1 = 
          {12{rv32_ecall             }} & 12'h341
        | {12{rv32_csrrw | rv32_csrrs}} & i_inst[31:20];

    assign o_wena1  = (rv32_ecall | rv32_csrrw | rv32_csrrs | rv32_csrrwi | rv32_csrrwi) & i_ena;

    assign o_wdata2 =
          {32{rv32_ecall             }} & 32'h0b
        | {32{rv32_mret              }} & 32'h80;

    assign o_waddr2 = 
          {12{rv32_ecall             }} & 12'h342 
        | {12{rv32_mret              }} & 12'h300;

    assign o_wena2  = (rv32_ecall | rv32_mret) & i_ena;

    assign o_raddr  = 
          {12{rv32_ecall                                         }} & 12'h305 
        | {12{rv32_mret                                          }} & 12'h341
        | {12{rv32_csrrw | rv32_csrrs | rv32_csrrwi | rv32_csrrwi}} & i_inst[31:20];


endmodule