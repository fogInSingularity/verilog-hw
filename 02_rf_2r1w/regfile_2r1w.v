module regfile_2r1w #(
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
    output reg [MEM_WIDTH-1 : 0]    o_rdata_a,

    input wire [ADDR_WIDTH-1 : 0]   i_raddr_b,
    output reg [MEM_WIDTH-1 : 0]    o_rdata_b
);

reg [MEM_WIDTH-1 : 0] mem [MEM_DEPTH-1 : 0];

always @(posedge clk) begin
    if (i_we)
        mem[i_waddr] <= i_wdata;
end

generate
if (IS_COMB_RD) begin : gen__comb_rd

    always @(*) begin
        o_rdata_a = mem[i_raddr_a];
        o_rdata_b = mem[i_raddr_b];
    end

end else begin : gen__ff_rd

    always @(posedge clk) begin
        o_rdata_a <= mem[i_raddr_a];
        o_rdata_b <= mem[i_raddr_b];
    end

end
endgenerate

endmodule
