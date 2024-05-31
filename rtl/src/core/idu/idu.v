module idu(
    // for idu performance count
    input            i_clk,
    input            i_rst,
    //from ifu
    input      [31:0]i_pc,
    input      [31:0]i_inst,
    //to exu

    output            o_reg_wena,
    output     [1:0]  o_reg_sel,
    //output     [ 2:0] o_wbu_package,

    output     [ 2:0] o_MemOp,
	output            o_MemWr,
    output            o_MemRe,
    //output     [ 3:0] o_slu_package,

    output            o_pc_sel,
    output     [ 2:0] o_branch,
    output     [ 3:0] o_alu_ctr,
    output            o_ALUAsrc,
	output     [ 1:0] o_ALUBsrc,
    //output     [10:0] o_exu_package,
    
    output     [31:0] o_pc,
    output     [31:0] o_imm,
    output     [31:0] o_src1,
    output     [31:0] o_src2,
    output     [31:0] o_inst,

    //read regfile
    output     [ 4:0] o_reg1_raddr,
    output     [ 4:0] o_reg2_raddr,
    input      [31:0] i_reg1_rdata,
    input      [31:0] i_reg2_rdata,
    //Handshake signal
    input            i_valid,
    output           o_ready,

    output           o_valid,
    input            i_ready
);


    wire [2:0] ext_opt;

    ContrGen  ContrGen_inst (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_valid(o_valid),
        .i_ready(i_ready),
        
        .i_inst(i_inst),
        .o_extopt(ext_opt),
        .o_reg_sel(o_reg_sel),
        .o_reg_wena(o_reg_wena),
        .o_MemWr(o_MemWr),
        .o_MemOp(o_MemOp),
        .o_MemRe(o_MemRe),
        .o_pc_sel(o_pc_sel),
        .o_branch(o_branch),
        .o_alu_ctr(o_alu_ctr),
        .o_ALUAsrc(o_ALUAsrc),
        .o_ALUBsrc(o_ALUBsrc)
    );

  
    ImmGen  ImmGen_inst (
        .inst(i_inst),
        .ext_opt(ext_opt),
        .imm(o_imm)
    );

    //read regfile
    assign o_reg1_raddr = i_inst[19:15];
    assign o_reg2_raddr = i_inst[24:20];


    //传递
    assign o_pc    = i_pc;
    assign o_src1  = i_reg1_rdata;
    assign o_src2  = i_reg2_rdata;
    assign o_inst  = i_inst;
    assign o_valid = i_valid;
    assign o_ready = i_ready;

endmodule