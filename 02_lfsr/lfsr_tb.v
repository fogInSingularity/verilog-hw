`timescale 1ns/1ps

module lfsr_tb;

localparam WIDTH = 8;

reg clk;
reg rst_n;

reg en;
wire [WIDTH-1 : 0] value;

lfsr dut (
    .clk(clk),
    .rst_n(rst_n),

    .i_en(en),
    .o_value(value)
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

    @(posedge clk) #1

    en = 1;

    #300
    $finish();
end

endmodule
