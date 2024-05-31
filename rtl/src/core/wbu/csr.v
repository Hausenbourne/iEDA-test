module csr(
    input        i_clk,
    input        i_rst_n,
    
    input  [31:0]i_csr_wdata1,
    input  [11:0]i_csr_waddr1,
    input        i_csr_wena1,

    input  [31:0]i_csr_wdata2,
    input  [11:0]i_csr_waddr2,
    input        i_csr_wena2,

    input  [11:0]i_csr_raddr,

    output [31:0]o_csr_rdata
);
    reg [31:0] csr [3:0];

    reg [1:0] w_idx1;
    reg [1:0] w_idx2;
    reg [2:0] r_idx ;

    always @(*) begin
        case(i_csr_waddr1)
            12'h300: w_idx1 = 2'b00;
            12'h305: w_idx1 = 2'b01;
            12'h341: w_idx1 = 2'b10;
            12'h342: w_idx1 = 2'b11;
            default: w_idx1 = 2'b00;////////
        endcase

        case(i_csr_waddr2)
            12'h300: w_idx2 = 2'b00;
            12'h305: w_idx2 = 2'b01;
            12'h341: w_idx2 = 2'b10;
            12'h342: w_idx2 = 2'b11;
            default: w_idx2 = 2'b00;////////
        endcase

        case(i_csr_raddr)
            12'h300: r_idx = 3'b000;
            12'h305: r_idx = 3'b001;
            12'h341: r_idx = 3'b010;
            12'h342: r_idx = 3'b011;
            12'hF11: r_idx = 3'b100;
            12'hF12: r_idx = 3'b101;
            default: r_idx = 3'b000;////////
        endcase
    end
    


    always@(posedge i_clk)begin 
        if(~i_rst_n)begin 
            csr[0] <= 32'b0;
            csr[1] <= 32'b0;
            csr[2] <= 32'b0;
            csr[3] <= 32'b0;
        end
        else begin 
            if(i_csr_wena1)begin
                csr[w_idx1] <= i_csr_wdata1;
            end
            if(i_csr_wena2)begin
                csr[w_idx2] <= i_csr_wdata2;
            end

        end
    end

    MuxKeyWithDefault #(6, 3, 32) csr_read_mux(o_csr_rdata, r_idx, 32'b0, {
        3'b000, csr[0],
        3'b001, csr[1],
        3'b010, csr[2],
        3'b011, csr[3],
        3'b100, 32'h79737978,
        3'b101, 32'h015FDE21
    });


endmodule