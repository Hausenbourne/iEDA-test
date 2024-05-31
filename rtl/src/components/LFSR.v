module LFSR(
	input       i_clk,
	input     i_rst_n,
	input     [7:0] d,
	output reg[7:0] q
);
	always@(posedge i_clk)
		if(~i_rst_n)
			q <= d;
		else
			q <= {q[4]^q[3]^q[2]^q[0],q[7:1]};
endmodule