`ifndef CDU_CONF_VH
`define CDU_CONF_VH

// alu sel {{{

`define ALU_SELW 2

`define SEL1_UIMM    2'h0
`define SEL1_BIMM    2'h1
`define SEL1_JIMM    2'h2
`define SEL1_RF_SRC1 2'h3

`define SEL2_RF_SRC2 2'h0
`define SEL2_IIMM    2'h1
`define SEL2_SIMM    2'h2
`define SEL2_PC      2'h3

// }}} alu sel 

// wb sel {{{

`define WB_SELW 2

`define WB_SEL_UIMM   2'h0
`define WB_SEL_ALU    2'h1
`define WB_SEL_LOAD   2'h2
`define WB_SEL_PC_INC 2'h3

// }}} wb sel

`endif // CDU_CONF_VH
