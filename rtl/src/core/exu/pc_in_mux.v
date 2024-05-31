module pc_in_mux(
    input  [31:0]A,
    input  [31:0]B,
    input        S,
    output [31:0]O
);
    assign O = S?A:B;
endmodule