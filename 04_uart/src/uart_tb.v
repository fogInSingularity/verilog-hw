`timescale 1ns/1ps

module uart_tb;

localparam RATE = 115200;
localparam DATAW = 8;

reg clk;
reg rst_n;

wire uart_tx2rx;

reg uart_vld;
reg [DATAW-1 : 0] uart_data;

wire uart_res_vld;
wire [DATAW-1 : 0] uart_res_data;

wire tx_ready;

uart_tx #(
    .RATE(RATE)
) uart_tx_dut (
    .clk(clk),
    .rst_n(rst_n),
    .o_tx(uart_tx2rx),
    .i_data(uart_data),
    .i_vld(uart_vld),

    .o_ready(tx_ready)
);

uart_rx #(
    .RATE(RATE)
) uart_rx_dut (
    .clk(clk),
    .rst_n(rst_n),
    .i_rx(uart_tx2rx),
    .o_data(uart_res_data),
    .o_vld(uart_res_vld)
);

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
end

always #10 clk = ~clk;

initial begin
    clk = '1;
    rst_n = '1;
    #1
    rst_n = '0;
    #1
    rst_n = '1;

    repeat (20) @(posedge clk);
    wait (tx_ready);
    repeat (20) @(posedge clk);
    uart_vld = 1'b1;
    uart_data = 8'b0011_0110; // 0x36

    @(posedge clk);
    uart_vld = 1'b0;

    wait (tx_ready);
    repeat (100) @(posedge clk);
    uart_vld = 1'b1;
    uart_data = 8'b1000_0000;

    @(posedge clk);
    uart_vld = 1'b0;
end

initial begin
    #500000
    $display("[%t] Timeout", $realtime);
    $finish();
end

endmodule
