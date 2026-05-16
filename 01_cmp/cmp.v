`include "cmp_ops.vh"

module cmp #(
    parameter WIDTH = 32,
    parameter SEL_WIDTH = `CMP_OPS_WIDTH
)(
    input wire [WIDTH-1 : 0] i_oprd1,
    input wire [WIDTH-1 : 0] i_oprd2,
    output reg               o_taken,

    input wire [SEL_WIDTH-1 : 0] i_sel
);

always @(*) begin
    case (i_sel)
        `BEQ:  o_taken = (i_oprd1 == i_oprd2);
        `BNE:  o_taken = (i_oprd1 != i_oprd2);
        `BLT:  o_taken = ($signed(i_oprd1) < $signed(i_oprd2));
        `BGE:  o_taken = ($signed(i_oprd1) >= $signed(i_oprd2));
        `BLTU: o_taken = (i_oprd1 < i_oprd2);
        `BGEU: o_taken = (i_oprd1 >= i_oprd2);
        default: o_taken = 1'bx;
    endcase
end

endmodule
