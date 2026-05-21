`define WIDTH 16

module system_top(
    input  wire CLK,
    input  wire RSTN,

    input wire [`WIDTH-1 : 0] i_a,
    input wire [`WIDTH-1 : 0] i_b,
    output reg [`WIDTH-1 : 0] o_res
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n  <= RSTN_d;
    RSTN_d <= RSTN;
end

always @(posedge CLK) begin
    o_res <= res;
    a <= i_a;
    b <= i_b;
end

reg [`WIDTH-1 : 0] a;
reg [`WIDTH-1 : 0] b;
wire [`WIDTH-1 : 0] res;

fp_add fp_add_isnt (
    .clk(CLK),
    .rst_n(rst_n),

    .i_a(a),
    .i_b(b),
    .o_res(res)
);

endmodule
