`ifndef CMP_OPS_VH_
`define CMP_OPS_VH_

localparam N_CMP_OPS = 6;
localparam CMP_OPS_WIDTH = $clog2(N_CMP_OPS);

typedef enum bit [CMP_OPS_WIDTH-1 : 0] {
    BEQ,
    BNE,
    BLT,
    BGE,
    BLTU,
    BGEU
} cmp_ops;

`endif // CMP_OPS_VH_
