module fp_add #(
    parameter EXP_WIDTH = 5,
    parameter MANT_WIDTH = 10,
    parameter WIDTH = 1 + EXP_WIDTH + MANT_WIDTH,
    parameter BIAS = (6'b1 << (EXP_WIDTH - 1)) - 1
)(
    input wire clk,
    input wire rst_n,

    input wire [WIDTH-1 : 0] i_a,
    input wire [WIDTH-1 : 0] i_b,
    output wire [WIDTH-1 : 0] o_res
);

// ADD_STAGE = add_*st.v
`ADD_STAGE #(
    .EXP_WIDTH(EXP_WIDTH),
    .MANT_WIDTH(MANT_WIDTH)
) add_stage_inst (
    .clk(clk),
    .rst_n(rst_n),

    .i_a(i_a),
    .i_b(i_b),
    .o_res(o_res)
);

endmodule