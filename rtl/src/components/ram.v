`ifdef CONFIG_YSYXSOC
`else

`ifdef SIMULATION
module spram  #(WIDTH = 32) (
    input                  clk_i  ,
    input [WIDTH   - 1: 0] addr_i ,
    input [WIDTH   - 1: 0] data_i ,
    input [WIDTH/8 - 1: 0] wmask_i,
    input                  ena_i  ,
    input                  wen_i  ,
    output[WIDTH   - 1: 0] data_o
);
    always @(posedge clk_i) begin
        if(ena_i) begin
            if(wen_i) begin
                mem_write(addr_i, data_i, {4'b0,wmask_i});
            end
            else begin
                mem_read(addr_i, data_o);
            end
        end
    end

endmodule



module tpram #(WIDTH = 32) (
    input                  clk_i  ,
    input [WIDTH   - 1: 0] waddr_i,
    input                  wena_i ,
    input [WIDTH/8 - 1: 0] wmask_i,
    input [WIDTH   - 1: 0] wdata_i,

    input [WIDTH   - 1: 0] raddr_i,
    input                  rena_i ,
    output[WIDTH   - 1: 0] rdata_o
);
    always @(posedge clk_i) begin
        if(wena_i) begin
            mem_write(addr_i, data_i, wmask_i);
        end
    end

    always @(posedge clk_i) begin
        if(rena_i) begin
            mem_read(addr_i, data_o);
        end
    end

endmodule


import "DPI-C" function void mem_write(input int waddr, input int wdata, input byte wmask);
import "DPI-C" function void mem_read(input int raddr, output int rdata);
`endif 

`endif
