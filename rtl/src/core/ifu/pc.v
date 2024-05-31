module pc(
	input            clk_i    ,
	input            rst_n_i  ,
	input            ena_i    ,
	input     [31:0] next_pc_i,
	output    [31:0] pc_o
);
	//pc
	wire rst = ~rst_n_i ;
	Reg # (32, 0) PC_inst (
		.clk (clk_i    ),
		.rst (rst      ),
		.din (next_pc_i),
		.dout(pc_o     ),
		.wen (ena_i    )
  	);
	
endmodule

