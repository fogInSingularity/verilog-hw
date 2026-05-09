`timescale 1ns/1ps

module clkdiv_tb;

localparam BASE_FREQ = 3;
localparam DIV_FREQ = 1;

reg clk;
reg div;
reg rst_n;

clkdiv #(
    .BASE_FREQ(BASE_FREQ),
    .DIV_FREQ(DIV_FREQ)
) dut (
    .rst_n(rst_n),
    .i_clk(clk),
    .o_clk(div)
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

    #300
    $finish();
end

endmodule
