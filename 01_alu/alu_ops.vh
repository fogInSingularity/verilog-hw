`ifndef ALU_OPS_VH_
`define ALU_OPS_VH_

localparam N_ALU_OPS = 10;
localparam ALU_OPS_WIDHT = $clog2(N_ALU_OPS);

typedef enum bit [ALU_OPS_WIDHT-1 : 0] {
    ADD,
    SUB, 
    SLL,
    SLT,
    SLTU,
    XOR,
    SRL,
    SRA,
    OR,
    AND
} alu_ops;

`endif // ALU_OPS_VH_
