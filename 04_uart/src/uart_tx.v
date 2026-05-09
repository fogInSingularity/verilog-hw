module uart_tx #(
    parameter RATE = 9600,
    parameter DATAW = 8
) (
    input wire clk,
    input wire rst_n,

    output wire o_tx,

    input wire [DATAW-1 : 0] i_data,
    input wire i_vld,

    output wire o_ready
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

uart_tx_ctrl #(
    .DATAW(DATAW)
) uart_tx_ctrl_inst (
    .clk(clk),
    .rate_clk(rate_clk),
    .rst_n(rst_n),

    .o_tx(o_tx),

    .i_data(i_data),
    .i_vld(i_vld),
    
    .o_ready(o_ready)
);

endmodule