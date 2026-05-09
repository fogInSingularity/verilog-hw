module top #(
    parameter RATE = 115200, // , 9600
    parameter DATAW = 8
) (
    input wire clk,
    input wire rst_n,

    output wire o_uart_tx,
    input wire i_uart_rx
);

wire [DATAW-1 : 0] data;
wire vld;

uart_tx #(
    .RATE(RATE),
    .DATAW(DATAW)
) uart_tx_inst (
    .clk(clk),
    .rst_n(rst_n),

    .o_tx(o_uart_tx),

    .i_data(data),
    .i_vld(vld)
);

uart_rx #(
    .RATE(RATE),
    .DATAW(DATAW)
) uart_rx_inst (
    .clk(clk),
    .rst_n(rst_n),

    .i_rx(i_uart_rx),

    .o_data(data),
    .o_vld(vld)
);

endmodule
