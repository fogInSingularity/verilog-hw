module system_top(
    input  wire CLK,
    input  wire RSTN,

    output wire UART_TX,
    input wire UART_RX
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n  <= RSTN_d;
    RSTN_d <= RSTN;
end

top top(
    .clk(CLK), 
    .rst_n(rst_n), 

    .o_uart_tx(UART_TX),
    .i_uart_rx(UART_RX)
);

endmodule
