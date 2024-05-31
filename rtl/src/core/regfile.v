module regfile(

	input            i_clk,
	input            i_rst_n,

	input      [ 4:0]i_reg1_raddr,
	output wire[31:0]o_reg1_rdata,

	input      [ 4:0]i_reg2_raddr,
	output wire[31:0]o_reg2_rdata,

	input       [ 4:0]i_reg_waddr,
	input       [31:0]i_reg_wdata,
	input             i_reg_wena
);

	reg [31:0] regs[31:1];

	//read reg
	assign o_reg1_rdata = (|i_reg1_raddr)?regs[i_reg1_raddr]:32'b0;
	assign o_reg2_rdata = (|i_reg2_raddr)?regs[i_reg2_raddr]:32'b0;

	//write reg

	integer i;
	always@(posedge i_clk)begin
	//always @(negedge i_clk ) begin
		if(~i_rst_n)begin
			for(i=1;i<=32;i=i+1)begin 
				regs[i] <= 32'b0;
			end
		end
		else begin 
			if(i_reg_wena && i_reg_waddr != 5'b0)begin
				regs[i_reg_waddr] <= i_reg_wdata;
			end
		end
	end

endmodule
