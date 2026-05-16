`include "alu_ops.vh"

module alu #(
    parameter WIDTH = 32,
    parameter SEL_WIDTH = `ALU_OPS_WIDTH
)(
    input  wire [WIDTH-1 : 0] i_oprd1,
    input  wire [WIDTH-1 : 0] i_oprd2,
    output reg  [WIDTH-1 : 0] o_res,

    input  wire [SEL_WIDTH-1 : 0] i_sel
);

localparam SHIFT_WIDTH = $clog2(WIDTH);

always @(*) begin
    case (i_sel)
        `ADD:  o_res = i_oprd1 + i_oprd2;
        `SUB:  o_res = i_oprd1 - i_oprd2;
        `SLL:  o_res = i_oprd1 << i_oprd2[SHIFT_WIDTH-1 : 0];
        `SLT:  o_res = $signed(i_oprd1) < $signed(i_oprd2) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
        `SLTU: o_res = i_oprd1 < i_oprd2 ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
        `XOR:  o_res = i_oprd1 ^ i_oprd2;
        `SRL:  o_res = i_oprd1 >> i_oprd2[SHIFT_WIDTH-1 : 0];
        `SRA:  o_res = i_oprd1 >>> i_oprd2[SHIFT_WIDTH-1 : 0];
        `OR:   o_res = i_oprd1 | i_oprd2;
        `AND:  o_res = i_oprd1 & i_oprd2;
        default: o_res = {WIDTH{1'bx}};
    endcase
end

endmodule
