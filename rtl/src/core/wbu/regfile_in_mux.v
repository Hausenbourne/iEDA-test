module regfile_in_mux(
    input  [31:0]A,
    input  [31:0]B,
    input  [31:0]C,
    input  [ 1:0]S,
    output [31:0]O
);

    MuxKeyWithDefault # (3, 2, 32) mux_inst(O, S, 32'b0, {
        2'b00,B,
        2'b01,A,
        2'b10,C
    });

endmodule