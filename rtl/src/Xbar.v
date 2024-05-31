module Xbar_NSoC(
    input          clk_i       ,
    input          rst_n_i     ,
    input  [ 3: 0] arid_i      ,
    input  [31: 0] araddr_i    ,
    input  [ 7: 0] arlen_i     ,
    input  [ 2: 0] arsize_i    ,
    input  [ 1: 0] arburst_i   ,
    input          arvalid_i   ,
    output         arready_o   ,
    
    output [ 3: 0] rid_o       ,
    output [31: 0] rdata_o     ,
    output [ 1: 0] rresp_o     ,
    output         rlast_o     ,
    output         rvalid_o    ,
    input          rready_i    ,

    input  [ 3: 0] awid_i      ,
    input  [31: 0] awaddr_i    ,
    input  [ 7: 0] awlen_i     ,
    input  [ 2: 0] awsize_i    ,
    input  [ 1: 0] awburst_i   ,
    input          awvalid_i   ,
    output         awready_o   ,

    input  [ 3: 0] wid_i       ,
    input  [31: 0] wdata_i     ,
    input  [ 3: 0] wstrb_i     ,
    input          wlast_i     ,
    input          wvalid_i    ,
    output         wready_o    ,

    output [ 3: 0] bid_o       ,
    output [ 1: 0] bresp_o     ,
    output         bvalid_o    ,
    input          bready_i    ,
    //slaver0
    output [ 3: 0] s0_arid_o   ,
    output [31: 0] s0_araddr_o ,
    output [ 7: 0] s0_arlen_o  ,
    output [ 2: 0] s0_arsize_o ,
    output [ 1: 0] s0_arburst_o,
    output         s0_arvalid_o,
    input          s0_arready_i,

    input  [ 3: 0] s0_rid_i    ,
    input  [31: 0] s0_rdata_i  ,
    input  [ 1: 0] s0_rresp_i  ,
    input          s0_rlast_i  ,
    input          s0_rvalid_i ,
    output         s0_rready_o ,

    output [ 3: 0] s0_awid_o   ,
    output [31: 0] s0_awaddr_o ,
    output [ 7: 0] s0_awlen_o  ,
    output [ 2: 0] s0_awsize_o ,
    output [ 1: 0] s0_awburst_o,
    output         s0_awvalid_o,
    input          s0_awready_i,

    output [ 3: 0] s0_wid_o    ,
    output [31: 0] s0_wdata_o  ,
    output [ 3: 0] s0_wstrb_o  ,
    output         s0_wlast_o  ,
    output         s0_wvalid_o ,
    input          s0_wready_i ,

    input  [ 3: 0] s0_bid_i    ,
    input  [ 1: 0] s0_bresp_i  ,
    input          s0_bvalid_i ,
    output         s0_bready_o ,
    //slaver1
    output [ 3: 0] s1_arid_o   ,
    output [31: 0] s1_araddr_o ,
    output [ 7: 0] s1_arlen_o  ,
    output [ 2: 0] s1_arsize_o ,
    output [ 1: 0] s1_arburst_o,
    output         s1_arvalid_o,
    input          s1_arready_i,

    input  [ 3: 0] s1_rid_i    ,
    input  [31: 0] s1_rdata_i  ,
    input  [ 1: 0] s1_rresp_i  ,
    input          s1_rlast_i  ,
    input          s1_rvalid_i ,
    output         s1_rready_o ,

    output [ 3: 0] s1_awid_o   ,
    output [31: 0] s1_awaddr_o ,
    output [ 7: 0] s1_awlen_o  ,
    output [ 2: 0] s1_awsize_o ,
    output [ 1: 0] s1_awburst_o,
    output         s1_awvalid_o,
    input          s1_awready_i,

    output [ 3: 0] s1_wid_o    ,
    output [31: 0] s1_wdata_o  ,
    output [ 3: 0] s1_wstrb_o  ,
    output         s1_wlast_o  ,
    output         s1_wvalid_o ,
    input          s1_wready_i ,

    input  [ 3: 0] s1_bid_i    ,
    input  [ 1: 0] s1_bresp_i  ,
    input          s1_bvalid_i ,
    output         s1_bready_o ,
    //slaver2
    output [ 3: 0] s2_arid_o   ,
    output [31: 0] s2_araddr_o ,
    output [ 7: 0] s2_arlen_o  ,
    output [ 2: 0] s2_arsize_o ,
    output [ 1: 0] s2_arburst_o,
    output         s2_arvalid_o,
    input          s2_arready_i,

    input  [ 3: 0] s2_rid_i    ,
    input  [31: 0] s2_rdata_i  ,
    input  [ 1: 0] s2_rresp_i  ,
    input          s2_rlast_i  ,
    input          s2_rvalid_i ,
    output         s2_rready_o ,

    output [ 3: 0] s2_awid_o   ,
    output [31: 0] s2_awaddr_o ,
    output [ 7: 0] s2_awlen_o  ,
    output [ 2: 0] s2_awsize_o ,
    output [ 1: 0] s2_awburst_o,
    output         s2_awvalid_o,
    input          s2_awready_i,

    output [ 3: 0] s2_wid_o    ,
    output [31: 0] s2_wdata_o  ,
    output [ 3: 0] s2_wstrb_o  ,
    output         s2_wlast_o  ,
    output         s2_wvalid_o ,
    input          s2_wready_i ,

    input  [ 3: 0] s2_bid_i    ,
    input  [ 1: 0] s2_bresp_i  ,
    input          s2_bvalid_i ,
    output         s2_bready_o
);
    localparam DEVICE_BASE =   32'ha0000000             ;
    localparam SERIAL_PORT =   DEVICE_BASE + 32'h00003f8;
    localparam SERIAL_LEN  =   32'h8                    ;
    localparam RTC_ADDR    =   DEVICE_BASE + 32'h0000048;
    localparam RTC_LEN     =   32'h8                    ;

    wire            rst = ~ rst_n_i                ;
    wire [31: 0] araddr = araddr_i & ~32'h3        ;
    wire [31: 0] awaddr = awaddr_i & ~32'h3        ;

    //CLINT 
    //wire S0_read_CS  = (araddr[31:16] == 16'h0200 );  
    //wire S0_write_CS = (awaddr[31:16] == 16'h0200 );
    wire S0_read_CS   = araddr >=  RTC_ADDR & araddr <= RTC_ADDR + RTC_LEN - 1;
    wire S0_write_CS  = awaddr >=  RTC_ADDR & awaddr <= RTC_ADDR + RTC_LEN - 1;

    //SRAM
    wire S1_read_CS  = (araddr[31:28] ==  4'h8    );
    wire S1_write_CS = (awaddr[31:28] ==  4'h8    );

    //UART
    //wire S2_read_CS  = (araddr[31:12] == 20'h10000);
    //wire S2_write_CS = (awaddr[31:12] == 20'h10000);
    wire S2_read_CS  = araddr >= SERIAL_PORT & araddr <= SERIAL_PORT + SERIAL_LEN - 1;
    wire S2_write_CS = awaddr >= SERIAL_PORT & awaddr <= SERIAL_PORT + SERIAL_LEN - 1;

    wire S3_read_CS  = ~(S0_read_CS  | S1_read_CS  | S2_read_CS );
    wire S3_write_CS = ~(S0_write_CS | S1_write_CS | S2_write_CS);
    // ===========================================================================
    // read Xbar state machine
    parameter READ_IDLE= 5'b00001          ;
    parameter S0_READ  = 5'b00010          ;
    parameter S1_READ  = 5'b00100          ;
    parameter S2_READ  = 5'b01000          ;
    parameter S3_READ  = 5'b10000          ;

    reg [ 4: 0] read_state, next_read_state;

    always @(posedge clk_i) begin
        if(rst) 
            read_state <= READ_IDLE        ;
        else
            read_state <= next_read_state  ;
    end

    always @(*) begin
        case(read_state)
            READ_IDLE: next_read_state = arvalid_i? (S0_read_CS? S0_READ: S1_read_CS? S1_READ: S2_read_CS? S2_READ: S3_READ): READ_IDLE; 
            S0_READ  : next_read_state = s0_rlast_i & s0_rvalid_i & rready_i? READ_IDLE: S0_READ;
            S1_READ  : next_read_state = s1_rlast_i & s1_rvalid_i & rready_i? READ_IDLE: S1_READ;
            S2_READ  : next_read_state = s2_rlast_i & s2_rvalid_i & rready_i? READ_IDLE: S2_READ;
            S3_READ  : next_read_state =                            rready_i? READ_IDLE: S3_READ;///////
            default  : next_read_state = S3_READ                                                ;
        endcase
    end

    assign s0_arid_o   = S0_read_CS? arid_i      : 4'b0;
    assign s0_araddr_o = S0_read_CS? araddr_i    :32'b0;
    assign s0_arlen_o  = S0_read_CS? arlen_i     : 8'b0;
    assign s0_arsize_o = S0_read_CS? arsize_i    : 3'b0;
    assign s0_arburst_o= S0_read_CS? arburst_i   : 2'b0;
    assign s0_arvalid_o= S0_read_CS? arvalid_i   : 1'b0;

    assign s0_rready_o = (read_state == S0_READ)? rready_i    : 1'b0;

    assign s1_arid_o   = S1_read_CS? arid_i      : 4'b0;
    assign s1_araddr_o = S1_read_CS? araddr_i    :32'b0;
    assign s1_arlen_o  = S1_read_CS? arlen_i     : 8'b0;
    assign s1_arsize_o = S1_read_CS? arsize_i    : 3'b0;
    assign s1_arburst_o= S1_read_CS? arburst_i   : 2'b0;
    assign s1_arvalid_o= S1_read_CS? arvalid_i   : 1'b0;

    assign s1_rready_o = (read_state == S1_READ)? rready_i    : 1'b0;

    assign s2_arid_o   = S2_read_CS? arid_i      : 4'b0;
    assign s2_araddr_o = S2_read_CS? araddr_i    :32'b0;
    assign s2_arlen_o  = S2_read_CS? arlen_i     : 8'b0;
    assign s2_arsize_o = S2_read_CS? arsize_i    : 3'b0;
    assign s2_arburst_o= S2_read_CS? arburst_i   : 2'b0;
    assign s2_arvalid_o= S2_read_CS? arvalid_i   : 1'b0;

    assign s2_rready_o = (read_state == S2_READ)? rready_i    : 1'b0;

    assign arready_o   = S0_read_CS? s0_arready_i: 
                         S1_read_CS? s1_arready_i: 
                         S2_read_CS? s2_arready_i: 
                         S3_read_CS?         1'b1: 
                         1'b0                    ;

    assign rid_o       = (read_state == S0_READ)? s0_rid_i  : 
                         (read_state == S1_READ)? s1_rid_i  : 
                         (read_state == S2_READ)? s2_rid_i  : 
                         (read_state == S3_READ)? 4'b0      : 
                         4'b0                               ;

    assign rdata_o     = (read_state == S0_READ)? s0_rdata_i:
                         (read_state == S1_READ)? s1_rdata_i:
                         (read_state == S2_READ)? s2_rdata_i:
                         (read_state == S3_READ)? 32'b0     :
                         32'b0                              ;    

    assign rresp_o     = (read_state == S0_READ)? s0_rresp_i:
                         (read_state == S1_READ)? s1_rresp_i:
                         (read_state == S2_READ)? s2_rresp_i:
                         (read_state == S3_READ)? 2'b11     : 
                         2'b0                               ;

    assign rlast_o     = (read_state == S0_READ)? s0_rlast_i:
                         (read_state == S1_READ)? s1_rlast_i:
                         (read_state == S2_READ)? s2_rlast_i:
                         (read_state == S3_READ)? 1'b1      :
                         1'b0                               ;

    assign rvalid_o    = (read_state == S0_READ)? s0_rvalid_i:
                         (read_state == S1_READ)? s1_rvalid_i:
                         (read_state == S2_READ)? s2_rvalid_i:
                         (read_state == S3_READ)?        1'b1:
                         1'b0                                ;

    // ===========================================================================
    // write Xbar state machine
    parameter WRITE_IDLE= 5'b00001           ;
    parameter S0_WRITE  = 5'b00010           ;
    parameter S1_WRITE  = 5'b00100           ;
    parameter S2_WRITE  = 5'b01000           ;
    parameter S3_WRITE  = 5'b10000           ;
    
    reg [ 4: 0] write_state, next_write_state;
    
    always @(posedge clk_i) begin
        if(rst) 
            write_state <= WRITE_IDLE        ;
        else
            write_state <= next_write_state   ;
    end

    
    
    always @(*) begin
        case(write_state)
            WRITE_IDLE: next_write_state = awvalid_i? (S0_write_CS? S0_WRITE: S1_write_CS? S1_WRITE: S2_write_CS? S2_WRITE: S3_WRITE): WRITE_IDLE; 
            S0_WRITE  : next_write_state = s0_bvalid_i & bready_i? WRITE_IDLE: S0_WRITE;
            S1_WRITE  : next_write_state = s1_bvalid_i & bready_i? WRITE_IDLE: S1_WRITE;
            S2_WRITE  : next_write_state = s2_bvalid_i & bready_i? WRITE_IDLE: S2_WRITE;
            //S3_WRITE  : next_write_state = s3_bvalid   & bready_i? WRITE_IDLE: S3_WRITE;
            S3_WRITE  : next_write_state =                                   WRITE_IDLE;//
            default   : next_write_state = S3_WRITE                                    ;
        endcase
    end
    
  

    assign s0_awid_o   = S0_write_CS? awid_i   :  4'b0;
    assign s0_awaddr_o = S0_write_CS? awaddr_i : 32'b0;
    assign s0_awlen_o  = S0_write_CS? awlen_i  :  8'b0;
    assign s0_awsize_o = S0_write_CS? awsize_i :  3'b0;
    assign s0_awburst_o= S0_write_CS? awburst_i:  2'b0;
    assign s0_awvalid_o= S0_write_CS? awvalid_i:  1'b0;
    assign s0_wid_o    = S0_write_CS? wid_i    :  4'b0;
    assign s0_wdata_o  = S0_write_CS? wdata_i  : 32'b0;
    assign s0_wstrb_o  = S0_write_CS? wstrb_i  :  4'b0;
    assign s0_wlast_o  = S0_write_CS? wlast_i  :  1'b0;
    assign s0_wvalid_o = S0_write_CS? wvalid_i :  1'b0;

    assign s0_bready_o = (write_state == S0_WRITE)? bready_i :  1'b0;

    assign s1_awid_o   = S1_write_CS? awid_i   :  4'b0;
    assign s1_awaddr_o = S1_write_CS? awaddr_i : 32'b0;
    assign s1_awlen_o  = S1_write_CS? awlen_i  :  8'b0;
    assign s1_awsize_o = S1_write_CS? awsize_i :  3'b0;
    assign s1_awburst_o= S1_write_CS? awburst_i:  2'b0;
    assign s1_awvalid_o= S1_write_CS? awvalid_i:  1'b0;
    assign s1_wid_o    = S1_write_CS? wid_i    :  4'b0;
    assign s1_wdata_o  = S1_write_CS? wdata_i  : 32'b0;
    assign s1_wstrb_o  = S1_write_CS? wstrb_i  :  4'b0;
    assign s1_wlast_o  = S1_write_CS? wlast_i  :  1'b0;
    assign s1_wvalid_o = S1_write_CS? wvalid_i :  1'b0;

    assign s1_bready_o = (write_state == S1_WRITE)? bready_i :  1'b0;

    assign s2_awid_o   = S2_write_CS? awid_i   :  4'b0;
    assign s2_awaddr_o = S2_write_CS? awaddr_i : 32'b0;
    assign s2_awlen_o  = S2_write_CS? awlen_i  :  8'b0;
    assign s2_awsize_o = S2_write_CS? awsize_i :  3'b0;
    assign s2_awburst_o= S2_write_CS? awburst_i:  2'b0;
    assign s2_awvalid_o= S2_write_CS? awvalid_i:  1'b0;
    assign s2_wid_o    = S2_write_CS? wid_i    :  4'b0;
    assign s2_wdata_o  = S2_write_CS? wdata_i  : 32'b0;
    assign s2_wstrb_o  = S2_write_CS? wstrb_i  :  4'b0;
    assign s2_wlast_o  = S2_write_CS? wlast_i  :  1'b0;
    assign s2_wvalid_o = S2_write_CS? wvalid_i :  1'b0;

    assign s2_bready_o = (write_state == S2_WRITE)? bready_i :  1'b0;

    assign awready_o   = S0_write_CS? s0_awready_i    :
                         S1_write_CS? s1_awready_i    :
                         S2_write_CS? s2_awready_i    :
                         S3_write_CS?         1'b1    :
                         1'b0                         ;

    assign wready_o    = S0_write_CS? s0_wready_i     :
                         S1_write_CS? s1_wready_i     :
                         S2_write_CS? s2_wready_i     :
                         S3_write_CS?         1'b1    :
                         1'b0                         ;

    assign bid_o       = (write_state == S0_WRITE)? s0_bid_i        :
                         (write_state == S1_WRITE)? s1_bid_i        :
                         (write_state == S2_WRITE)? s2_bid_i        :
                         (write_state == S3_WRITE)?         4'b0    :
                         4'b0                                       ;
    assign bresp_o     = (write_state == S0_WRITE)? s0_bresp_i      :
                         (write_state == S1_WRITE)? s1_bresp_i      :
                         (write_state == S2_WRITE)? s2_bresp_i      :
                         (write_state == S3_WRITE)?        2'b11    :
                         2'b00                                      ;
    assign bvalid_o    = (write_state == S0_WRITE)? s0_bvalid_i     :
                         (write_state == S1_WRITE)? s1_bvalid_i     :
                         (write_state == S2_WRITE)? s2_bvalid_i     :
                         (write_state == S3_WRITE)?         1'b1    :
                         1'b0                                       ;

endmodule


module Xbar(
    input          clk_i       ,
    input          rst_n_i     ,
    input  [ 3: 0] arid_i      ,
    input  [31: 0] araddr_i    ,
    input  [ 7: 0] arlen_i     ,
    input  [ 2: 0] arsize_i    ,
    input  [ 1: 0] arburst_i   ,
    input          arvalid_i   ,
    output         arready_o   ,
    
    output [ 3: 0] rid_o       ,
    output [31: 0] rdata_o     ,
    output [ 1: 0] rresp_o     ,
    output         rlast_o     ,
    output         rvalid_o    ,
    input          rready_i    ,

    input  [ 3: 0] awid_i      ,
    input  [31: 0] awaddr_i    ,
    input  [ 7: 0] awlen_i     ,
    input  [ 2: 0] awsize_i    ,
    input  [ 1: 0] awburst_i   ,
    input          awvalid_i   ,
    output         awready_o   ,

    input  [ 3: 0] wid_i       ,
    input  [31: 0] wdata_i     ,
    input  [ 3: 0] wstrb_i     ,
    input          wlast_i     ,
    input          wvalid_i    ,
    output         wready_o    ,

    output [ 3: 0] bid_o       ,
    output [ 1: 0] bresp_o     ,
    output         bvalid_o    ,
    input          bready_i    ,
    //slaver0
    output [ 3: 0] s0_arid_o   ,
    output [31: 0] s0_araddr_o ,
    output [ 7: 0] s0_arlen_o  ,
    output [ 2: 0] s0_arsize_o ,
    output [ 1: 0] s0_arburst_o,
    output         s0_arvalid_o,
    input          s0_arready_i,

    input  [ 3: 0] s0_rid_i    ,
    input  [31: 0] s0_rdata_i  ,
    input  [ 1: 0] s0_rresp_i  ,
    input          s0_rlast_i  ,
    input          s0_rvalid_i ,
    output         s0_rready_o ,

    output [ 3: 0] s0_awid_o   ,
    output [31: 0] s0_awaddr_o ,
    output [ 7: 0] s0_awlen_o  ,
    output [ 2: 0] s0_awsize_o ,
    output [ 1: 0] s0_awburst_o,
    output         s0_awvalid_o,
    input          s0_awready_i,

    output [ 3: 0] s0_wid_o    ,
    output [31: 0] s0_wdata_o  ,
    output [ 3: 0] s0_wstrb_o  ,
    output         s0_wlast_o  ,
    output         s0_wvalid_o ,
    input          s0_wready_i ,

    input  [ 3: 0] s0_bid_i    ,
    input  [ 1: 0] s0_bresp_i  ,
    input          s0_bvalid_i ,
    output         s0_bready_o ,
    //slaver1
    output [ 3: 0] s1_arid_o   ,
    output [31: 0] s1_araddr_o ,
    output [ 7: 0] s1_arlen_o  ,
    output [ 2: 0] s1_arsize_o ,
    output [ 1: 0] s1_arburst_o,
    output         s1_arvalid_o,
    input          s1_arready_i,

    input  [ 3: 0] s1_rid_i    ,
    input  [31: 0] s1_rdata_i  ,
    input  [ 1: 0] s1_rresp_i  ,
    input          s1_rlast_i  ,
    input          s1_rvalid_i ,
    output         s1_rready_o ,

    output [ 3: 0] s1_awid_o   ,
    output [31: 0] s1_awaddr_o ,
    output [ 7: 0] s1_awlen_o  ,
    output [ 2: 0] s1_awsize_o ,
    output [ 1: 0] s1_awburst_o,
    output         s1_awvalid_o,
    input          s1_awready_i,

    output [ 3: 0] s1_wid_o    ,
    output [31: 0] s1_wdata_o  ,
    output [ 3: 0] s1_wstrb_o  ,
    output         s1_wlast_o  ,
    output         s1_wvalid_o ,
    input          s1_wready_i ,

    input  [ 3: 0] s1_bid_i    ,
    input  [ 1: 0] s1_bresp_i  ,
    input          s1_bvalid_i ,
    output         s1_bready_o 
);

    wire            rst = ~ rst_n_i                ;
    wire [31: 0] araddr = araddr_i & ~32'h3        ;
    wire [31: 0] awaddr = awaddr_i & ~32'h3        ;

    //CLINT 
    wire S0_read_CS  = (araddr[31:16] == 16'h0200 );  
    wire S0_write_CS = (awaddr[31:16] == 16'h0200 );

    //Other
    wire S1_read_CS  = ~ S0_read_CS ;
    wire S1_write_CS = ~ S0_write_CS;

    // ===========================================================================
    // read Xbar state machine
    parameter READ_IDLE= 3'b001;
    parameter S0_READ  = 3'b010;
    parameter S1_READ  = 3'b100;

    reg [ 2: 0] read_state, next_read_state;

    always @(posedge clk_i) begin
        if(rst) 
            read_state <= READ_IDLE        ;
        else
            read_state <= next_read_state  ;
    end

    always @(*) begin
        case(read_state)
            READ_IDLE: next_read_state = arvalid_i? (S0_read_CS? S0_READ: S1_READ): READ_IDLE   ; 
            S0_READ  : next_read_state = s0_rlast_i & s0_rvalid_i & rready_i? READ_IDLE: S0_READ;
            S1_READ  : next_read_state = s1_rlast_i & s1_rvalid_i & rready_i? READ_IDLE: S1_READ;
            default  : next_read_state = READ_IDLE                                              ;
        endcase
    end

    assign s0_arid_o   = S0_read_CS? arid_i      : 4'b0;
    assign s0_araddr_o = S0_read_CS? araddr_i    :32'b0;
    assign s0_arlen_o  = S0_read_CS? arlen_i     : 8'b0;
    assign s0_arsize_o = S0_read_CS? arsize_i    : 3'b0;
    assign s0_arburst_o= S0_read_CS? arburst_i   : 2'b0;
    assign s0_arvalid_o= S0_read_CS? arvalid_i   : 1'b0;
    

    assign s0_rready_o = (read_state == S0_READ)? rready_i    : 1'b0;

    assign s1_arid_o   = S1_read_CS? arid_i      : 4'b0;
    assign s1_araddr_o = S1_read_CS? araddr_i    :32'b0;
    assign s1_arlen_o  = S1_read_CS? arlen_i     : 8'b0;
    assign s1_arsize_o = S1_read_CS? arsize_i    : 3'b0;
    assign s1_arburst_o= S1_read_CS? arburst_i   : 2'b0;
    assign s1_arvalid_o= S1_read_CS? arvalid_i   : 1'b0;

    assign s1_rready_o = (read_state == S1_READ)? rready_i    : 1'b0;


    assign arready_o   = S0_read_CS? s0_arready_i             : 
                         S1_read_CS? s1_arready_i             :  
                         1'b0                                 ;

    assign rid_o       = (read_state == S0_READ)? s0_rid_i    : 
                         (read_state == S1_READ)? s1_rid_i    : 
                         4'b0                                 ;

    assign rdata_o     = (read_state == S0_READ)? s0_rdata_i  :
                         (read_state == S1_READ)? s1_rdata_i  :
                         32'b0                                ;

    assign rresp_o     = (read_state == S0_READ)? s0_rresp_i  :
                         (read_state == S1_READ)? s1_rresp_i  :
                         2'b0                                 ;

    assign rlast_o     = (read_state == S0_READ)? s0_rlast_i  :
                         (read_state == S1_READ)? s1_rlast_i  :
                         1'b0                                 ;


    assign rvalid_o    = (read_state == S0_READ)? s0_rvalid_i :
                         (read_state == S1_READ)? s1_rvalid_i :
                         1'b0                                 ;

    // ===========================================================================
    // write Xbar state machine
    parameter WRITE_IDLE= 3'b001;
    parameter S0_WRITE  = 3'b010;
    parameter S1_WRITE  = 3'b100;

    
    reg [ 2: 0] write_state, next_write_state;
    
    always @(posedge clk_i) begin
        if(rst) 
            write_state <= WRITE_IDLE        ;
        else
            write_state <= next_write_state  ;
    end

    
    
    always @(*) begin
        case(write_state)
            WRITE_IDLE: next_write_state = awvalid_i? (S0_write_CS? S0_WRITE: S1_WRITE): WRITE_IDLE; 
            S0_WRITE  : next_write_state = s0_bvalid_i & bready_i? WRITE_IDLE: S0_WRITE            ;
            S1_WRITE  : next_write_state = s1_bvalid_i & bready_i? WRITE_IDLE: S1_WRITE            ;
            default   : next_write_state = WRITE_IDLE                                              ;
        endcase
    end
    
    assign s0_awid_o   = S0_write_CS? awid_i   :  4'b0;
    assign s0_awaddr_o = S0_write_CS? awaddr_i : 32'b0;
    assign s0_awlen_o  = S0_write_CS? awlen_i  :  8'b0;
    assign s0_awsize_o = S0_write_CS? awsize_i :  3'b0;
    assign s0_awburst_o= S0_write_CS? awburst_i:  2'b0;
    assign s0_awvalid_o= S0_write_CS? awvalid_i:  1'b0;
    assign s0_wid_o    = S0_write_CS? wid_i    :  4'b0;
    assign s0_wdata_o  = S0_write_CS? wdata_i  : 32'b0;
    assign s0_wstrb_o  = S0_write_CS? wstrb_i  :  4'b0;
    assign s0_wlast_o  = S0_write_CS? wlast_i  :  1'b0;
    assign s0_wvalid_o = S0_write_CS? wvalid_i :  1'b0;
    
    assign s0_bready_o = (write_state == S0_WRITE)? bready_i :  1'b0;

    assign s1_awid_o   = S1_write_CS? awid_i   :  4'b0;
    assign s1_awaddr_o = S1_write_CS? awaddr_i : 32'b0;
    assign s1_awlen_o  = S1_write_CS? awlen_i  :  8'b0;
    assign s1_awsize_o = S1_write_CS? awsize_i :  3'b0;
    assign s1_awburst_o= S1_write_CS? awburst_i:  2'b0;
    assign s1_awvalid_o= S1_write_CS? awvalid_i:  1'b0;
    assign s1_wid_o    = S1_write_CS? wid_i    :  4'b0;
    assign s1_wdata_o  = S1_write_CS? wdata_i  : 32'b0;
    assign s1_wstrb_o  = S1_write_CS? wstrb_i  :  4'b0;
    assign s1_wlast_o  = S1_write_CS? wlast_i  :  1'b0;
    assign s1_wvalid_o = S1_write_CS? wvalid_i :  1'b0;

    assign s1_bready_o = (write_state == S1_WRITE)? bready_i :  1'b0;

    assign awready_o   = S0_write_CS? s0_awready_i                  :
                         S1_write_CS? s1_awready_i                  :
                         1'b0                                       ;

    assign wready_o    = S0_write_CS? s0_wready_i                   :
                         S1_write_CS? s1_wready_i                   :
                         1'b0                                       ;

    assign bid_o       = (write_state == S0_WRITE)? s0_bid_i        :
                         (write_state == S1_WRITE)? s1_bid_i        :
                         4'b0                                       ;

    assign bresp_o     = (write_state == S0_WRITE)? s0_bresp_i      :
                         (write_state == S1_WRITE)? s1_bresp_i      :
                         2'b00                                      ;

    assign bvalid_o    = (write_state == S0_WRITE)? s0_bvalid_i     :
                         (write_state == S1_WRITE)? s1_bvalid_i     :
                         1'b0                                       ;

endmodule