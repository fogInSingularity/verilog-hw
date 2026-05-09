`timescale 1ns/1ps

module fifo_tb;

localparam DEPTH = 2;
localparam WIDTH = 1;

reg clk;
reg rst_n;

reg [WIDTH-1 : 0] i_wr_data;
reg i_wr_en;
wire o_wr_full;

wire [WIDTH-1 : 0] o_rd_data;
reg i_rd_en;
wire o_rd_empty;

fifo #(
    .DEPTH(DEPTH),
    .WIDTH(WIDTH)
) dut (
    .clk(clk),
    .rst_n(rst_n),

    .i_wr_data(i_wr_data),
    .i_wr_en(i_wr_en),
    .o_wr_full(o_wr_full),

    .o_rd_data(o_rd_data),
    .i_rd_en(i_rd_en),
    .o_rd_empty(o_rd_empty)
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

    i_wr_data = '1;
    i_wr_en = '1;

    @(posedge clk) #1

    i_wr_data = '0;
    i_wr_en = '1;

    @(posedge clk) #1

    i_wr_en = '0;

    @(posedge clk) #1
    @(posedge clk) #1

    i_rd_en = '1;

    @(posedge clk) #1
    @(posedge clk) #1

    i_rd_en = '0;

    #300
    $finish();
end

endmodule
