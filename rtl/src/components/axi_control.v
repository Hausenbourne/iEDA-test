module axi_master#(
    parameter AXI_BURST_LEN    = 4,
    parameter AXI_ID_WIDTH     = 6,
    parameter AXI_ADDR_WIDTH   = 32,
    parameter AXI_DATA_WIDTH   = 32,
    parameter AXI_AWUSER_WIDTH = 0,
    parameter AXI_ARUSER_WIDTH = 0,
    parameter AXI_WUSER_WIDTH  = 0,
    parameter AXI_RUSER_WIDTH  = 0,
    parameter AXI_BUSER_WIDTH  = 0
)

(
    input                          i_clk      ,
    input                          i_rst_n    ,
    //AR
    output [AXI_ID_WIDTH-1    : 0] o_arid     ,
    output [AXI_ADDR_WIDTH-1  : 0] o_araddr   ,
    output [7                 : 0] o_arlen    ,
    output [2                 : 0] o_arsize   ,
    output [1                 : 0] o_arburst  ,
    output                         o_arlock   ,
    output [3                 : 0] o_arcache  ,
    output [2                 : 0] o_arprot   ,
    output [3                 : 0] o_arqos    ,
    output [3                 : 0] o_arregion ,
    output [AXI_ARUSER_WIDTH-1: 0] o_aruser   ,
    output                         o_arvalid  ,
    input                          i_arready  ,
    //R  
    input                          i_rid      ,//
    input  [AXI_DATA_WIDTH-1  : 0] i_rdata    ,
    input                          i_rresp    ,//
    input                          i_rlast    ,
    input                          i_ruser    ,
    input                          i_rvalid   ,
    output                         o_rready   ,
    //AW
    output [AXI_ID_WIDTH-1    : 0] o_awid     ,
    output [AXI_ADDR_WIDTH-1  : 0] o_awaddr   ,
    output [7                 : 0] o_awlen    ,
    output [2                 : 0] o_awsize   ,
    output [1                 : 0] o_awburst  ,
    output                         o_awlock   ,
    output [3                 : 0] o_awcache  ,
    output [2                 : 0] o_awprot   ,                 
    output [3                 : 0] o_awqos    ,
    output [3                 : 0] o_awregion ,
    output [AXI_AWUSER_WIDTH-1: 0] o_awuser   ,
    output                         o_awvalid  ,
    input                          i_awready  ,
    //W
    output [AXI_DATA_WIDTH-1  : 0] o_wdata    ,
    output [AXI_DATA_WIDTH/8-1: 0] o_wstrb    ,
    output                         o_wlast    ,
    output [AXI_WUSER_WIDTH-1 : 0] o_wuser    ,
    output                         o_wvalid   ,
    input                          i_wready   ,

    //B
    input  [AXI_ID_WIDTH-1    : 0] i_bid      ,
    input  [1                 : 0] i_bresp    ,
    input  [AXI_BUSER_WIDTH-1 : 0] i_buser    ,
    input                          i_bvalid   ,
    output                         o_bready 
);

    /*****************************function**************************/
    //计算二进制位宽
    function integer clogb2(input integer number);
        begin
            for(clogb2 = 0; number > 0; clogb2 = clogb2 + 1)
                number = number >> 1; 
        end
    endfunction
    /***************************parameter***************************/
    parameter ST_IDLE        = 3'b000           ;
           
    parameter ST_WRITE_START = 3'b001           ;
    parameter ST_WRITE_TRANS = 3'b010           ;
    parameter ST_WRITE_END   = 3'b100           ;
           
    parameter ST_READ_START  = 3'b001           ;
    parameter ST_READ_TRANS  = 3'b010           ;
    parameter ST_READ_END    = 3'b100           ;
    /*************************state machine*************************/
    reg [ 2                : 0] read_state      ; 
    reg [ 2                : 0] next_read_state ;
    reg [ 2                : 0] write_state     ;
    reg [ 2                : 0] next_write_state;

    always @(posedge i_clk) begin
        if(w_system_rst)
            write_state <= ST_IDLE;
        else
            write_state <= next_write_state;
    end

    always @(*) begin
        case (write_state)
            ST_IDLE       : next_write_state = ST_WRITE_START;
            ST_WRITE_START: next_write_state = r_write_start? ST_WRITE_TRANS: ST_WRITE_START;
            ST_WRITE_TRANS: next_write_state = o_wlast      ? ST_WRITE_END  : ST_WRITE_TRANS;
            ST_WRITE_END  : next_write_state = (read_state == ST_READ_END)? ST_IDLE:ST_WRITE_END;
            default       : next_write_state = ST_IDLE;      
        endcase
    end

    always @(posedge i_clk) begin
        if(write_state == ST_WRITE_START)
            r_write_start <= 1'b1;
        else
            r_write_start <= 1'b0;    
    end




    always @(posedge i_clk) begin
        if(w_system_rst)
            read_state <= ST_IDLE;
        else
            read_state <= next_read_state;
    end

    always @(*) begin
        case (read_state)
            ST_IDLE      : next_read_state = (write_state == ST_WRITE_END)? ST_READ_START: ST_IDLE;
            ST_READ_START: next_read_state = r_read_start? ST_READ_TRANS: ST_READ_START;
            ST_READ_TRANS: next_read_state = i_rlast     ? ST_READ_END  : ST_READ_TRANS;
            ST_READ_END  : next_read_state = ST_IDLE;
            default      : next_read_state = ST_IDLE;      
        endcase
    end

    always @(posedge i_clk) begin
        if(read_state == ST_READ_START)
            r_read_start <= 1'b1;
        else
            r_read_start <= 1'b0;    
    end


    /****************************register***************************/
    //AR 
    reg [AXI_ADDR_WIDTH - 1: 0] r_araddr         ;
    reg                         r_arvalid        ;
    reg                         r_read_start     ;
    //R        
    reg                         r_rready         ;
    reg [AXI_DATA_WIDTH - 1: 0] r_rdata          ;
    //AW        
    reg [AXI_ADDR_WIDTH - 1: 0] r_awaddr         ;
    reg                         r_awvalid        ;
    reg                         r_write_start    ;
    reg [7                 : 0] r_burst_cnt      ;
    //W    
    reg [AXI_DATA_WIDTH - 1: 0] r_wdata          ; 
    reg                         r_wlast          ;
    reg                         r_wvalid         ;
    /****************************netlist****************************/
    wire w_system_rst = ~ i_rst_n ;
    /**********************combinational logic**********************/
    //AR
    assign o_arid   = 'b0                        ;//

    assign o_arlen  = AXI_BURST_LEN              ;
    assign o_arsize = clogb2(AXI_DATA_WIDTH/8 -1);
    assign o_arburst= 2'b01                      ;
    assign o_arlock = 'b0                        ;
    assign o_arcache= 4'b0010                    ;
    assign o_arprot = 'b0                        ;
    assign o_arqos  = 'b0                        ;
    assign o_aruser = 'b0                        ;
    assign o_araddr = r_araddr                   ;
    assign o_arvalid= r_arvalid                  ;
    //R
    assign o_rready = r_rready                   ;
    //AW
    assign o_awid   = 'b0                        ;//
    assign o_awlen  = AXI_BURST_LEN              ;
    assign o_awsize = clogb2(AXI_DATA_WIDTH/8 -1);
    assign o_awburst= 2'b01                      ;
    assign o_awlock = 'b0                        ;
    assign o_awcache= 4'b0010                    ;
    assign o_awprot = 'b0                        ;
    assign o_awqos  = 'b0                        ;
    assign o_awuser = 'b0                        ;
    assign o_awaddr = r_awaddr                   ;
    assign o_awvalid= r_awvalid                  ;
    //W
    assign o_wstrb  = {AXI_DATA_WIDTH/8{1'b1}}   ;
    assign o_wuser  = 'b0                        ;
    assign o_wdata  = r_wdata                    ;
    assign o_wlast  = r_wlast                    ;
    assign o_wvalid = r_awvalid                  ;
    //B
    assign o_bready = 1'b1                       ;//



    /*************************instantiation*************************/
    /****************************process****************************/
    //AR
    always @(posedge i_clk) begin
        if(w_system_rst | (o_arvalid & i_arready))
            r_arvalid <= 'b0;
        else if(r_read_start)
            r_arvalid <= 'b1;
        else
            r_arvalid <= r_arvalid;
    end

    always @(posedge i_clk) begin
        if(r_read_start)
            r_araddr <= 'b0;//根据具体情况修改
        else
            r_araddr <= 'b0;
    end

    
    //R
    always @(posedge i_clk) begin
        if(w_system_rst | i_rlast)
            r_rready <= 1'b0;
        else if(o_arvalid & i_arready)
            r_rready <= 1'b1;
        else
            r_rready <= r_rready;        
    end
    
    always @(posedge i_clk) begin
        if(i_rvalid & o_rready)      
            r_rdata <= i_rdata;
        else
            r_rdata <= r_rdata;
    end

    //AW
    always @(posedge i_clk) begin
        if(w_system_rst |(o_awvalid & i_awready))
            r_awvalid <= 'b0;
        else if( r_write_start)
            r_awvalid <= 'b1;
        else
            r_awvalid <= r_awvalid;
    end

    always @(posedge i_clk) begin
        if(w_system_rst)
            r_awaddr <= 'b0;
        else if(r_write_start)
            r_awaddr <= 'b0;//根据实际情况修改
        else
            r_awaddr <= r_awaddr;  
    end
    //W
    always @(posedge i_clk) begin
        if(w_system_rst)
            r_wvalid <= 'b0;
        else if(o_awvalid & i_awready)
            r_wvalid <= 'b1;
       else
            r_wvalid <= r_wvalid; 
    end

    always @(posedge i_clk) begin
        if(w_system_rst | o_wlast)
            r_wdata  <= 'b0;
        else if(o_wvalid & i_wready)
            r_wdata  <= r_wdata + 1;//根据实际情况修改
        else
            r_wdata  <= r_wdata;
    end

    always @(posedge i_clk) begin
        //burst len > 2
        if(w_system_rst)
            r_wlast  <= 'b0;
        else if(r_burst_cnt == AXI_BURST_LEN - 2)
            r_wlast  <= 'b1;
        else
            r_wlast  <= 'b0;
    end

    always @(posedge i_clk) begin
        if(w_system_rst)
            r_burst_cnt  <= 'b0;
        else if(o_wvalid & i_wready)
            r_burst_cnt  <= r_burst_cnt + 1;
        else
            r_burst_cnt  <= r_burst_cnt;
    end

    


endmodule


module axi_lite_slaver(
    input          clk,
    input          rst_n,
    //AR
    input  [31: 0] araddr,
    input          arvalid,
    output         arready,
    //R
    output [31: 0] rdata,
    output         rresp,
    output         rvalid,
    input          rready,
    //AW
    input  [31: 0] awaddr,
    input          awvalid,
    output         awready,
    //W
    input  [31: 0] wdata,
    input  [ 3: 0] wstrb,
    input          wvalid,
    output         wready,
    //B
    output         bresp,
    output         bvalid,
    input          bready
);

endmodule
