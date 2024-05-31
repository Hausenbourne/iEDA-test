`define ZeroReg        5'b0
`define WriteEnable    1'b1
`define WriteDisable   1'b0


`define INST_TYPE_R1   7'b0110011
`define INST_TYPE_R2   7'b0111011

`define INST_TYPE_I1   7'b1100111
`define INST_TYPE_I2   7'b0000011
`define INST_TYPE_I3   7'b0010011
`define INST_TYPE_I4   7'b0011011
`define INST_TYPE_I5   7'b0001111
`define INST_TYPE_I6   7'b1110011

`define INST_TYPE_S1   7'b0100011

`define INST_TYPE_B1   7'b1100111

`define INST_TYPE_U1   7'b0110111
`define INST_TYPE_U2   7'b0010111

`define INST_TYPE_J1   7'b1101111


`define OPERATE_ADD    4'b0000
`define OPERATE_SUB    4'b1000
`define OPERATE_SLL    4'bx001
`define OPERATE_SLT    4'b0010
`define OPERATE_SLTU   4'b1010
`define OPERATE_B      4'bx011
`define OPERATE_XOR    4'bx100
`define OPERATE_SRL    4'b0101
`define OPERATE_SRA    4'b1101
`define OPERATE_OR     4'bx110
`define OPERATE_AND    4'bx111


`define INS_FETCH           32'd0

`define IFU_WAIT            32'd1
`define IFU_DELAY           32'd2
`define IFU_TRANS           32'd3

`define INT_OPE_INS         32'd4
`define LOAD_INS            32'd5
`define STORE_INS           32'd6
`define CONT_TRANS_INS      32'd7
`define ENV_CALL_BREAK_INS  32'd8
`define CSR_INS             32'd9
`define TRA_RET             32'd10
`define IDU_NOT_WORK        32'd11

`define EXU_CAL             32'd12
`define EXU_NOT_WORK        32'd13

`define LSU_WAIT            32'd14
`define LSU_LOAD_DELAY      32'd15
`define LSU_STORE_DELAY     32'd16
`define LSU_TRANS           32'd17

`define WBU_WAIT            32'd18
`define WBU_TRANS           32'd19

`define CYCLE               32'd20

//`define CONFIG_IFU_RDG     1
//`define CONFIG_SLU_RDG     1
//`define CONFIG_SRAM_RDG    1





