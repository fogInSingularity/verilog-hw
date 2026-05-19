`include "rv32i.vh"

module regfile #(
    parameter MEM_DEPTH = `N_REGS,
    parameter MEM_WIDTH = `REGW,
    parameter ADDR_WIDTH = `REG_ADDRW,
    parameter IS_COMB_RD = 1'b0
)(
    input wire clk,

    input wire                      i_we,
    input wire [ADDR_WIDTH-1 : 0]   i_waddr,
    input wire [MEM_WIDTH-1 : 0]    i_wdata,

    input wire [ADDR_WIDTH-1 : 0]   i_raddr_a,
    output reg [MEM_WIDTH-1 : 0]    o_rdata_a,

    input wire [ADDR_WIDTH-1 : 0]   i_raddr_b,
    output reg [MEM_WIDTH-1 : 0]    o_rdata_b
);

wire [MEM_WIDTH-1 : 0] rdata_a;
wire [MEM_WIDTH-1 : 0] rdata_b;

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

// x0 + bypass

always @(*) begin
    if (i_raddr_a == 'b0)                    o_rdata_a = 'b0;
    else if (i_we && (i_raddr_a == i_waddr)) o_rdata_a = i_wdata;
    else                                     o_rdata_a = rdata_a;
end

always @(*) begin
    if (i_raddr_b == 'b0)                    o_rdata_b = 'b0;
    else if (i_we && (i_raddr_b == i_waddr)) o_rdata_b = i_wdata;
    else                                     o_rdata_b = rdata_b;
end

endmodule
