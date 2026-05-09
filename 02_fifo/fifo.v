module fifo #(
    parameter DEPTH = 2, // must be power of 2
    parameter WIDTH = 8
) (
    input wire clk,
    input wire rst_n,

    input wire [WIDTH-1 : 0] i_wr_data,
    input wire i_wr_en,
    output reg o_wr_full,

    output wire [WIDTH-1 : 0] o_rd_data,
    input wire i_rd_en,
    output wire o_rd_empty
);

localparam ADDR_WIDTH = $clog2(DEPTH);

// -1 +1
reg [ADDR_WIDTH : 0] head;
reg [ADDR_WIDTH : 0] tail;

mem1r1w #(
    .MEM_DEPTH(DEPTH),
    .MEM_WIDTH(WIDTH)
) mem (
    .clk(clk),

    .i_we(i_wr_en),
    .i_waddr(head[ADDR_WIDTH-1 : 0]),
    .i_wdata(i_wr_data),

    .i_raddr(tail[ADDR_WIDTH-1 : 0]),
    .o_rdata(o_rd_data)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        head <= '0;
        tail <= '0;
    end else begin
        if (i_wr_en)
            head <= head + 1;
        if (i_rd_en)
            tail <= tail + 1;
    end
end

wire is_addr_same;
assign is_addr_same = head[ADDR_WIDTH-1 : 0] == tail[ADDR_WIDTH-1 : 0];

wire is_msb_same;
assign is_msb_same = head[ADDR_WIDTH] == tail[ADDR_WIDTH];

assign o_wr_full = is_addr_same && !is_msb_same;
assign o_rd_empty = is_addr_same && is_msb_same;

endmodule
