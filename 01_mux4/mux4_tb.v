`timescale 1ns/1ps

module mux4_tb;

localparam WIDTH = 2;
localparam SEL_WIDTH = 2;

reg [WIDTH-1 : 0] val0;
reg [WIDTH-1 : 0] val1;
reg [WIDTH-1 : 0] val2;
reg [WIDTH-1 : 0] val3;
reg [SEL_WIDTH-1 : 0] sel;

wire [WIDTH-1 : 0] res;

mux4 #(
    .WIDTH(WIDTH)
) dut (
    .i_val0(val0),
    .i_val1(val1),
    .i_val2(val2),
    .i_val3(val3),

    .i_sel(sel),
    .o_res(res)
);

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
end

initial begin
    #1;
    val0 = 2'h0;
    val1 = 2'h1;
    val2 = 2'h2;
    val3 = 2'h3;

    #10;

    sel = 2'h2;

    #10;

    sel = 2'h3;

    #10;
end

endmodule
