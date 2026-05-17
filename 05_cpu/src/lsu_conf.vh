`ifndef LSU_CONF_VH_
`define LSU_CONF_VH_

`define LSU_MASKW 4

`define LSU_SELW 2
`define INST_LSU_LOAD   `LSU_SELW'h0
`define INST_LSU_STORE  `LSU_SELW'h1
`define INST_LSU_IGNORE `LSU_SELW'h2

`endif // LSU_CONF_VH_
