`ifndef ALU_OPS_VH_
`define ALU_OPS_VH_

`define N_ALU_OPS 10
`define ALU_OPS_WIDTH $clog2(`N_ALU_OPS)

`define ADD  4'h0
`define SUB  4'h1
`define SLL  4'h2
`define SLT  4'h3
`define SLTU 4'h4
`define XOR  4'h5
`define SRL  4'h6
`define SRA  4'h7
`define OR   4'h8
`define AND  4'h9

`endif // ALU_OPS_VH_
