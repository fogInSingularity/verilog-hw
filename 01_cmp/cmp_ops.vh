`ifndef CMP_OPS_VH_
`define CMP_OPS_VH_

`define N_CMP_OPS 6
`define CMP_OPS_WIDTH $clog2(`N_CMP_OPS)

`define BEQ  3'h0
`define BNE  3'h1
`define BLT  3'h2
`define BGE  3'h3
`define BLTU 3'h4
`define BGEU 3'h5

`endif // CMP_OPS_VH_
