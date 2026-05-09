module uart_rx #(
    parameter RATE = 50,
    parameter DATAW = 8
) (
    input wire clk,
    input wire rst_n,

    input wire i_rx,

    output wire [DATAW-1 : 0] o_data,
    output wire o_vld
);

wire rate_clk;

clkdiv #(
    .BASE_FREQ(50_000_000),
    .DIV_FREQ(RATE)
) clkdiv_inst (
    .rst_n(rst_n),

    .i_clk(clk),
    .o_clk(rate_clk)
);

wire rx_sync;

sync_1bit #(
    .INIT_VAL(1'b1)
) sync_1bit_rx (
    .clk(rate_clk),
    .rst_n(rst_n),

    .i_async(i_rx),
    .o_sync(rx_sync)
);

wire rx_edge;

negedge_detector negedge_detector_inst (
    .clk(rate_clk),
    .rst_n(rst_n),

    .i_signal(rx_sync),
    .o_edge(rx_edge)
);

uart_rx_ctrl uart_rx_ctrl_inst (
    .clk(clk),
    .rate_clk(rate_clk),
    .rst_n(rst_n),

    .i_rx_sync(rx_sync),
    .i_rx_edge(rx_edge),
    
    .o_data(o_data),
    .o_vld(o_vld)
);

endmodule