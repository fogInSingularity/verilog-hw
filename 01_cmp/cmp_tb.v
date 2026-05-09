`timescale 1ns/1ps

`include "cmp_ops.vh"

module cmp_tb;

localparam WIDTH = 32;
localparam SEL_WIDTH = CMP_OPS_WIDTH;

reg [WIDTH-1 : 0] val1;
reg [WIDTH-1 : 0] val2;
reg [SEL_WIDTH-1 : 0] sel;

reg taken;

cmp #(
    .WIDTH(WIDTH)
) dut (
    .i_oprd1(val1),
    .i_oprd2(val2),
    .o_taken(taken),

    .i_sel(sel)
);

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
end

task check(
    input [WIDTH-1 : 0] v1,
    input [WIDTH-1 : 0] v2,
    input cmp_ops       op,

    input expected
);
    val1 = v1;
    val2 = v2;
    sel = op;
    #1

    if (taken != expected) 
        $display("[FAIL] res %h, expected %h", taken, expected);
    else
        $display("[PASS] res %h, expected %h", taken, expected);
endtask

initial begin
    #1
    check(1, 1, BEQ, 1);
    check(2, 1, BEQ, 0);
    check(1, 0, BNE, 1);
    check(1, 2, BLT, 1);
    check(1, 0, BLT, 0);
end

endmodule
