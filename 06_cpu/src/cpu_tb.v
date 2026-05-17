`timescale 1ns/100ps

`include "rv32i.vh"

module cpu_tb;

localparam DISPLAYW = 16;

reg clk;
reg rst_n;

wire [DISPLAYW-1 : 0] display_data;

cpu cpu_inst (
    .clk(clk),
    .rst_n(rst_n),

    .o_display_data(display_data)
);

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
end

always #10 clk = ~clk;
initial begin

    // clk = 0;
    // rst_n = 0;

    // @(posedge clk);
    // @(posedge clk);
    // rst_n = 0;

    clk = '1;
    rst_n = '1;
    #1
    rst_n = '0;
    #1
    rst_n = '1;

    @(posedge clk);
end

initial begin
    #1000
    $display("[%t] Timeout", $realtime);
    $finish();
end

endmodule