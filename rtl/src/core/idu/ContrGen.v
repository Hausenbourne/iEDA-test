module ContrGen(
	// for idu performance count
	input             i_clk,
	input             i_rst,
	input             i_valid,
	input             i_ready,

	//from ifu
	input      [31:0] i_inst,
	//to ImmGen
	output     [ 2:0] o_extopt,
	//to regfile_in_mux
	output     [ 1:0] o_reg_sel,
	//to  reg_file
	output            o_reg_wena,
	//to DataMem
	output            o_MemWr,
	output     [ 2:0] o_MemOp,
	output            o_MemRe,
	//to pc_in_mux
	output            o_pc_sel,
	//to Branch
	output     [ 2:0] o_branch,

	//to alu_in_mux
	output            o_ALUAsrc,
	output     [ 1:0] o_ALUBsrc,
	//to alu
	output     [ 3:0] o_alu_ctr
);

	
	wire[ 6:0]  opcode      = i_inst[ 6: 0];
	wire [2:0]  rv32_func3  = i_inst[14:12];
	wire [6:0]  rv32_func7  = i_inst[31:25];

	wire opcode_1_0_00  = (opcode[1:0] == 2'b00);
  	wire opcode_1_0_01  = (opcode[1:0] == 2'b01);
 	wire opcode_1_0_10  = (opcode[1:0] == 2'b10);
  	wire opcode_1_0_11  = (opcode[1:0] == 2'b11);

	// We generate the signals and reused them as much as possible to save gatecounts
	wire opcode_4_2_000 = (opcode[4:2] == 3'b000);
	wire opcode_4_2_001 = (opcode[4:2] == 3'b001);
	wire opcode_4_2_010 = (opcode[4:2] == 3'b010);
	wire opcode_4_2_011 = (opcode[4:2] == 3'b011);
	wire opcode_4_2_100 = (opcode[4:2] == 3'b100);
	wire opcode_4_2_101 = (opcode[4:2] == 3'b101);
	wire opcode_4_2_110 = (opcode[4:2] == 3'b110);
	wire opcode_4_2_111 = (opcode[4:2] == 3'b111);
	wire opcode_6_5_00  = (opcode[6:5] == 2'b00);
	wire opcode_6_5_01  = (opcode[6:5] == 2'b01);
	wire opcode_6_5_10  = (opcode[6:5] == 2'b10);
	wire opcode_6_5_11  = (opcode[6:5] == 2'b11);
  
	wire rv32_func3_000 = (rv32_func3 == 3'b000);
	wire rv32_func3_001 = (rv32_func3 == 3'b001);
	wire rv32_func3_010 = (rv32_func3 == 3'b010);
	wire rv32_func3_011 = (rv32_func3 == 3'b011);
	wire rv32_func3_100 = (rv32_func3 == 3'b100);
	wire rv32_func3_101 = (rv32_func3 == 3'b101);
	wire rv32_func3_110 = (rv32_func3 == 3'b110);
	wire rv32_func3_111 = (rv32_func3 == 3'b111);
  
  
	wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000);
	wire rv32_func7_0100000 = (rv32_func7 == 7'b0100000);
	wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001);
	wire rv32_func7_0000101 = (rv32_func7 == 7'b0000101);
	wire rv32_func7_0001001 = (rv32_func7 == 7'b0001001);
	wire rv32_func7_0001101 = (rv32_func7 == 7'b0001101);
	wire rv32_func7_0010101 = (rv32_func7 == 7'b0010101);
	wire rv32_func7_0100001 = (rv32_func7 == 7'b0100001);
	wire rv32_func7_0010001 = (rv32_func7 == 7'b0010001);
	wire rv32_func7_0101101 = (rv32_func7 == 7'b0101101);
	wire rv32_func7_1111111 = (rv32_func7 == 7'b1111111);
	wire rv32_func7_0000100 = (rv32_func7 == 7'b0000100); 
	wire rv32_func7_0001000 = (rv32_func7 == 7'b0001000); 
	wire rv32_func7_0001100 = (rv32_func7 == 7'b0001100); 
	wire rv32_func7_0101100 = (rv32_func7 == 7'b0101100); 
	wire rv32_func7_0010000 = (rv32_func7 == 7'b0010000); 
	wire rv32_func7_0010100 = (rv32_func7 == 7'b0010100); 
	wire rv32_func7_1100000 = (rv32_func7 == 7'b1100000); 
	wire rv32_func7_1110000 = (rv32_func7 == 7'b1110000); 
	wire rv32_func7_1010000 = (rv32_func7 == 7'b1010000); 
	wire rv32_func7_1101000 = (rv32_func7 == 7'b1101000); 
	wire rv32_func7_1111000 = (rv32_func7 == 7'b1111000); 
	wire rv32_func7_1010001 = (rv32_func7 == 7'b1010001);  
	wire rv32_func7_1110001 = (rv32_func7 == 7'b1110001);  
	wire rv32_func7_1100001 = (rv32_func7 == 7'b1100001);  
	wire rv32_func7_1101001 = (rv32_func7 == 7'b1101001);  
	
	//R
  	wire rv32_op       = opcode_6_5_01 & opcode_4_2_100 & opcode_1_0_11;
	//I
	wire rv32_jalr     = opcode_6_5_11 & opcode_4_2_001 & opcode_1_0_11;
	wire rv32_load     = opcode_6_5_00 & opcode_4_2_000 & opcode_1_0_11; 
	wire rv32_op_imm   = opcode_6_5_00 & opcode_4_2_100 & opcode_1_0_11;
	wire rv32_system   = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11;
	//S
	wire rv32_store    = opcode_6_5_01 & opcode_4_2_000 & opcode_1_0_11; 
	//B
	wire rv32_branch   = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11; 
	//U 
	wire rv32_auipc    = opcode_6_5_00 & opcode_4_2_101 & opcode_1_0_11; 
	wire rv32_lui      = opcode_6_5_01 & opcode_4_2_101 & opcode_1_0_11;
	//J
	wire rv32_jal      = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11; 

	

	// ===========================================================================
  	// Branch Instructions
	wire rv32_beq      = rv32_branch & rv32_func3_000;
	wire rv32_bne      = rv32_branch & rv32_func3_001;
	wire rv32_blt      = rv32_branch & rv32_func3_100;
	wire rv32_bge      = rv32_branch & rv32_func3_101;
	wire rv32_bltu     = rv32_branch & rv32_func3_110;
	wire rv32_bgeu     = rv32_branch & rv32_func3_111;

	 // ===========================================================================
  	// ALU Instructions
	wire rv32_addi     = rv32_op_imm & rv32_func3_000;
	wire rv32_slti     = rv32_op_imm & rv32_func3_010;
	wire rv32_sltiu    = rv32_op_imm & rv32_func3_011;
	wire rv32_xori     = rv32_op_imm & rv32_func3_100;
	wire rv32_ori      = rv32_op_imm & rv32_func3_110;
	wire rv32_andi     = rv32_op_imm & rv32_func3_111;
  
	wire rv32_slli     = rv32_op_imm & rv32_func3_001 & (i_inst[31:26] == 6'b000000);
	wire rv32_srli     = rv32_op_imm & rv32_func3_101 & (i_inst[31:26] == 6'b000000);
	wire rv32_srai     = rv32_op_imm & rv32_func3_101 & (i_inst[31:26] == 6'b010000);
  
	wire rv32_add      = rv32_op     & rv32_func3_000 & rv32_func7_0000000;
	wire rv32_sub      = rv32_op     & rv32_func3_000 & rv32_func7_0100000;
	wire rv32_sll      = rv32_op     & rv32_func3_001 & rv32_func7_0000000;
	wire rv32_slt      = rv32_op     & rv32_func3_010 & rv32_func7_0000000;
	wire rv32_sltu     = rv32_op     & rv32_func3_011 & rv32_func7_0000000;
	wire rv32_xor      = rv32_op     & rv32_func3_100 & rv32_func7_0000000;
	wire rv32_srl      = rv32_op     & rv32_func3_101 & rv32_func7_0000000;
	wire rv32_sra      = rv32_op     & rv32_func3_101 & rv32_func7_0100000;
	wire rv32_or       = rv32_op     & rv32_func3_110 & rv32_func7_0000000;
	wire rv32_and      = rv32_op     & rv32_func3_111 & rv32_func7_0000000;

	
  
 	// ===========================================================================
    // Load/Store Instructions
	wire rv32_lb       = rv32_load   & rv32_func3_000;
	wire rv32_lh       = rv32_load   & rv32_func3_001;
	wire rv32_lw       = rv32_load   & rv32_func3_010;
	wire rv32_lbu      = rv32_load   & rv32_func3_100;
	wire rv32_lhu      = rv32_load   & rv32_func3_101;
  
	wire rv32_sb       = rv32_store  & rv32_func3_000;
	wire rv32_sh       = rv32_store  & rv32_func3_001;
	wire rv32_sw       = rv32_store  & rv32_func3_010;


	wire rv32_imm_sel_i = rv32_op_imm | rv32_jalr | rv32_load;
	wire rv32_imm_sel_u = rv32_lui | rv32_auipc;
	wire rv32_imm_sel_s = rv32_store;
	wire rv32_imm_sel_b = rv32_branch;
	wire rv32_imm_sel_j = rv32_jal;
	// ===========================================================================
 	// System Instructions
	wire rv32_ebreak   = rv32_system & rv32_func3_000 & (i_inst[31:20] == 12'b0000_0000_0001);
	wire rv32_ecall    = rv32_system & rv32_func3_000 & (i_inst[31:20] == 12'b0000_0000_0000);
    wire rv32_mret     = rv32_system & rv32_func3_000 & (i_inst[31:20] == 12'b0011_0000_0010);
	wire rv32_csrrw    = rv32_system & rv32_func3_001; 
    wire rv32_csrrs    = rv32_system & rv32_func3_010;
    wire rv32_csrrwi   = rv32_system & rv32_func3_101; 
    wire rv32_csrrsi   = rv32_system & rv32_func3_110; 
	// ===========================================================================
	//for ImmGen
	assign o_extopt = 
          {3{rv32_imm_sel_i}} & 3'b000
        | {3{rv32_imm_sel_u}} & 3'b001
        | {3{rv32_imm_sel_s}} & 3'b010
        | {3{rv32_imm_sel_b}} & 3'b011
        | {3{rv32_imm_sel_j}} & 3'b100;
	// ===========================================================================
	//for alu_in_mux
	assign o_ALUAsrc = 
		  rv32_auipc 
		| rv32_jal 
		| rv32_jalr;

	assign o_ALUBsrc = 
		  {2{rv32_lui | rv32_auipc  | rv32_op_imm | rv32_load | rv32_store}}  & 2'b01
		| {2{rv32_jal | rv32_jalr}} & 2'b10;
	// ===========================================================================
	//for alu
	assign o_alu_ctr = 
		  {4{rv32_auipc | rv32_addi  | rv32_add | rv32_jal | rv32_jalr | rv32_load  | rv32_store}} & 4'b0000
		| {4{rv32_sub}} & 4'b1000
		| {4{rv32_slli  | rv32_sll}} & 4'bX001
		| {4{rv32_slti  | rv32_slt   |rv32_beq  | rv32_bne | rv32_blt  | rv32_bge}} & 4'b0010
		| {4{rv32_sltiu | rv32_sltu  | rv32_bltu| rv32_bgeu}}          & 4'b1010
		| {4{rv32_lui}} & 4'bx011
		| {4{rv32_xori  | rv32_xor}} & 4'bx100
		| {4{rv32_srli  | rv32_srl}} & 4'b0101
		| {4{rv32_srai  | rv32_sra}} & 4'b1101
		| {4{rv32_ori   | rv32_or }} & 4'bx110
		| {4{rv32_andi  | rv32_and}} & 4'bx111;
	// ===========================================================================
	//for BranchCond
	assign o_branch = 
		  {3{rv32_jal            }} & 3'b001
		| {3{rv32_jalr           }} & 3'b010
		| {3{rv32_beq            }} & 3'b100
		| {3{rv32_bne            }} & 3'b101
		| {3{rv32_blt | rv32_bltu}} & 3'b110
		| {3{rv32_bge | rv32_bgeu}} & 3'b111;
	// ===========================================================================
	//for pc_im_mux
	assign o_pc_sel = rv32_ecall | rv32_mret;
	// ===========================================================================
	//for DataMem
	assign o_MemOp = 
	      {3{rv32_lb | rv32_sb}} & 3'b000
		| {3{rv32_lh | rv32_sh}} & 3'b001
		| {3{rv32_lw | rv32_sw}} & 3'b010
		| {3{rv32_lbu         }} & 3'b100
		| {3{rv32_lhu         }} & 3'b101;

	assign o_MemWr = rv32_store;
	assign o_MemRe = rv32_load;
	// ===========================================================================
	//for regfile_in_mux
	assign o_reg_sel = 
		  {2{rv32_lb    | rv32_lh    | rv32_lw     | rv32_lbu   | rv32_lhu}} & 2'b01
		| {2{rv32_csrrs | rv32_csrrw | rv32_csrrsi | rv32_csrrwi          }} & 2'b10;
	// ===========================================================================
	//for regfile
	assign o_reg_wena   = 
		  rv32_op 
		| rv32_jalr 
		| rv32_op_imm 
		| rv32_auipc 
		| rv32_lui 
		| rv32_jal 
		| rv32_load 
		| rv32_csrrw 
		| rv32_csrrs 
		| rv32_csrrwi 
		| rv32_csrrsi;

	// ===========================================================================
	//for invalid_inst
	`ifdef SIMULATION
	import "DPI-C" function void INVALID_INST(input int thispc);
	`endif
	// ===========================================================================
	//for ebreak
	`ifdef SIMULATION
	import "DPI-C" function void CHECK_FINISH(input ebreak);
	always@(posedge i_clk)begin 
		CHECK_FINISH(rv32_ebreak);
	end
	`endif
	// ===========================================================================
	//for performance
	`ifdef SIMULATION
	`ifdef CONFIG_PERF
	import "DPI-C" function void PREF_COUNT(input int ev);
	wire rv32_env  = rv32_ebreak | rv32_ecall;
	wire rv32_csr  = rv32_csrrw | rv32_csrrs | rv32_csrrwi | rv32_csrrsi;
	always@(posedge i_clk) begin
		if(~i_rst ) begin
			if(i_valid & i_ready) begin
				if(rv32_op | rv32_op_imm | rv32_lui | rv32_auipc) begin
					PREF_COUNT(`INT_OPE_INS);
				end
	
				if(rv32_load) begin
					PREF_COUNT(`LOAD_INS);
				end
	
				if(rv32_store) begin
					PREF_COUNT(`STORE_INS);
				end
	
				if(rv32_jal | rv32_jalr | rv32_branch) begin
					PREF_COUNT(`CONT_TRANS_INS);
				end
	
				if(rv32_env) begin
					PREF_COUNT(`ENV_CALL_BREAK_INS);
				end
	
				if(rv32_csr) begin
					PREF_COUNT(`CSR_INS);
				end
	
				if(rv32_mret) begin
					PREF_COUNT(`TRA_RET);
				end
			end
			else begin
				PREF_COUNT(`IDU_NOT_WORK);
			end
		end			
	end
	`endif
	`endif
endmodule

	
	
