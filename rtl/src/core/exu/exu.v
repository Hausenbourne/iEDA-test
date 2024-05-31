module exu(
    // for performance
    input            i_clk,
    input            i_rst,
    //to ifu
    output    [31:0] o_next_pc,
    //from wbu
    input     [31:0] i_csr_src,
    //from idu
    input            i_reg_wena,
    input     [ 1:0] i_reg_sel,
    //input     [ 2:0] i_wbu_package,

    input            i_MemWr,
    input     [ 2:0] i_MemOp,
    input            i_MemRe,
    //input     [ 3:0] i_slu_package,


    input            i_pc_sel,
    input     [ 2:0] i_branch,
    input     [ 3:0] i_alu_ctr,
    input            i_ALUAsrc,
    input     [ 1:0] i_ALUBsrc,
    //input     [10:0] i_exu_package,

    
    input     [31:0] i_pc,
    input     [31:0] i_imm,
    input     [31:0] i_src1,
    input     [31:0] i_src2,
    input     [31:0] i_inst,
    
    //to slu
    output            o_reg_wena,
    output     [ 1:0] o_reg_sel,
    //output     [ 2:0] o_wbu_package,

    output            o_MemWr,
    output     [ 2:0] o_MemOp,
    output            o_MemRe,
    //output     [ 3:0] o_slu_package,
	
    output     [31:0] o_ALUout,
    output     [31:0] o_pc,
    output     [31:0] o_imm,

    output     [31:0] o_src1,
    output     [31:0] o_src2,

    output     [31:0] o_inst,

    //Handshake signal
    input            i_valid,
    output           o_ready,

    output           o_valid,
    input            i_ready

);
    

    wire [31:0]A;
    wire [31:0]B;

    alu_in_mux  alu_in_mux_inst (
        .pc(i_pc),
        .src1(i_src1),
        .src2(i_src2),
        .imm(i_imm),
        .ALUAsrc(i_ALUAsrc),
        .ALUBsrc(i_ALUBsrc),
        .A(A),
        .B(B)
    );

    wire  Less;
    wire  Zero;

    ALU  ALU_inst (
        .A(A),
        .B(B),
        .ALUctr(i_alu_ctr),
        .ALUout(o_ALUout),
        .Less(Less),
        .Zero(Zero)
    );

    wire  PCAsrc;
    wire  PCBsrc;

    BranchCond  BranchCond_inst (
        .Branch(i_branch),
        .Zero(Zero),
        .Less(Less),
        .PCAsrc(PCAsrc),
        .PCBsrc(PCBsrc)
    );



    wire [31:0]o_PcGen_next_pc;
    PcGen  PcGen_inst (
        .imm(i_imm),
        .pc(i_pc),
        .src1(i_src1),
        .PCAsrc(PCAsrc),
        .PCBsrc(PCBsrc),
        .next_pc(o_PcGen_next_pc)
    );

    wire [31: 0] next_pc;
    pc_in_mux  pc_in_mux_inst (
        .A(i_csr_src),
        .B(o_PcGen_next_pc),
        .S(i_pc_sel),
        .O(next_pc)
    );

    `ifdef CONFIG_YSYXSOC
    localparam RESET_VECTOR = 32'h20000000;
    `else
    localparam RESET_VECTOR = 32'h80000000;
    `endif

    Reg # (32, RESET_VECTOR) pc_reg_inst (i_clk, i_rst, next_pc, o_next_pc, o_valid & i_ready);
    
    //传递
    assign o_reg_wena = i_reg_wena;
    assign o_reg_sel  = i_reg_sel;
    //assign o_wbu_package = i_wbu_package;

    assign o_MemWr    = i_MemWr; 
    assign o_MemOp    = i_MemOp;
    assign o_MemRe    = i_MemRe;
    //assign o_slu_package = i_slu_package;

    assign o_pc       = i_pc;
    assign o_src1     = i_src1;
    assign o_src2     = i_src2;
    assign o_inst     = i_inst;

    assign o_valid    = i_valid;
    assign o_ready    = i_ready;


    // performance count
    `ifdef SIMULATION
    `ifdef CONFIG_PERF
    import "DPI-C" function void PREF_COUNT(input int ev);
    always@(posedge i_clk) begin
        if(~i_rst )begin
            if(o_valid & i_ready) begin
                PREF_COUNT(`EXU_CAL);
            end
            else begin
                PREF_COUNT(`EXU_NOT_WORK);
            end
        end
    end
    `endif
    `endif

    `ifdef SIMULATION
    import "DPI-C" function void EXU_TRACE(input int next_pc);
    always@(posedge i_clk) begin
        if(o_valid & i_ready)begin
            EXU_TRACE(next_pc);
        end
    end
    `endif
    

endmodule