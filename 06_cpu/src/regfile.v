module regfile #(
    parameter MEM_DEPTH = 32,
    parameter MEM_WIDTH = 32,
    parameter ADDR_WIDTH = $clog2(MEM_DEPTH),
    parameter IS_COMB_RD = 1'b0
)(
    input wire clk,

    input wire                      i_we,
    input wire [ADDR_WIDTH-1 : 0]   i_waddr,
    input wire [MEM_WIDTH-1 : 0]    i_wdata,

    input wire [ADDR_WIDTH-1 : 0]   i_raddr_a,
    output wire [MEM_WIDTH-1 : 0]   o_rdata_a,

    input wire [ADDR_WIDTH-1 : 0]   i_raddr_b,
    output wire [MEM_WIDTH-1 : 0]   o_rdata_b
);

wire [MEM_WIDTH-1 : 0]   rdata_a;
wire [MEM_WIDTH-1 : 0]   rdata_b;

regfile_2r1w #(
    .MEM_DEPTH(MEM_DEPTH),
    .MEM_WIDTH(MEM_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .IS_COMB_RD(IS_COMB_RD)
) regfile_2r1w_inst (
    .clk(clk),

    .i_we(i_we),
    .i_waddr(i_waddr),
    .i_wdata(i_wdata),

    .i_raddr_a(i_raddr_a),
    .o_rdata_a(rdata_a),

    .i_raddr_b(i_raddr_b),
    .o_rdata_b(rdata_b)
);

assign o_rdata_a = (i_raddr_a == 0) ? 0 : rdata_a;
assign o_rdata_b = (i_raddr_b == 0) ? 0 : rdata_b;

endmodule
