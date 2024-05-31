module wbu(
    input            i_clk,
    input            i_rst_n,
    //from slu
    input            i_reg_wena,
    input     [1:0]  i_reg_sel,
    //input     [ 2:0] i_wbu_package,

    input     [31:0] i_mem_rdata,
    input     [31:0] i_ALUout,
    input     [31:0] i_pc,
    input     [31:0] i_imm,
    input     [31:0] i_src1,
    input     [31:0] i_inst,

    //write regfile
    output     [31:0] o_reg_wdata,
    output     [ 4:0] o_reg_waddr,
    output            o_reg_wena,
    //to ifu
    output            o_done,
    //to exu
    output     [31:0] o_csr_src,
    //Handshake signal
    input             i_valid,
    output            o_ready
);


    wire [31:0] csr_src;

    wire [31:0] wdata1;
    wire [11:0] waddr1;
    wire        wena1;

    wire [31:0] wdata2;
    wire [11:0] waddr2;
    wire        wena2;

    wire [11:0] raddr;

    wire csr_ena;
    csr_control  csr_control_inst (
        .i_pc(i_pc),
        .i_imm(i_imm),
        .i_src1(i_src1),
        .i_inst(i_inst),
        .i_csr_src(csr_src),
        .i_ena(csr_ena),
        .o_wdata1(wdata1),
        .o_waddr1(waddr1),
        .o_wena1(wena1),
        .o_wdata2(wdata2),
        .o_waddr2(waddr2),
        .o_wena2(wena2),
        .o_raddr(raddr)
    );

    csr  csr_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_csr_wdata1(wdata1),
        .i_csr_waddr1(waddr1),
        .i_csr_wena1(wena1),
        .i_csr_wdata2(wdata2),
        .i_csr_waddr2(waddr2),
        .i_csr_wena2(wena2),
        .i_csr_raddr(raddr),
        .o_csr_rdata(csr_src)
    );

    regfile_in_mux  regfile_in_mux_inst (
        .A(i_mem_rdata),
        .B(i_ALUout),
        .C(csr_src),
        .S(i_reg_sel),
        .O(o_reg_wdata)
    );

    wbu_control  wbu_control_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_reg_wena(i_reg_wena),
        .o_reg_wena(o_reg_wena),
        .o_csr_ena(csr_ena),
        .o_done(o_done),
        .i_valid(i_valid),
        .o_ready(o_ready)
    );

    //向后传递
    assign o_reg_waddr  = i_inst[11:7];
    assign o_csr_src    = csr_src;

endmodule