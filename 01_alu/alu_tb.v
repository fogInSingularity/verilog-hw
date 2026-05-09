`timescale 1ns/1ps

`include "alu_ops.vh"

module alu_tb;

localparam WIDTH = 32;
localparam SEL_WIDTH = ALU_OPS_WIDHT;

reg [WIDTH-1 : 0] val1;
reg [WIDTH-1 : 0] val2;
reg [SEL_WIDTH-1 : 0] sel;

reg [WIDTH-1 : 0] res;

alu #(
    .WIDTH(WIDTH)
) dut (
    .i_oprd1(val1),
    .i_oprd2(val2),
    .o_res(res),

    .i_sel(sel)
);

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
end

task check(
    input [WIDTH-1 : 0] v1,
    input [WIDTH-1 : 0] v2,
    input alu_ops       op,
    input [WIDTH-1 : 0] expected
);
    val1 = v1;
    val2 = v2;
    sel = op;
    #1

    if (res != expected) 
        $display("[FAIL] res %h, expected %h", res, expected);
    else
        $display("[PASS] res %h, expected %h", res, expected);
endtask

initial begin
    #1
    check(1, 2, ADD, 3);
    check(2, 1, SUB, 1);
    check(1, 0, AND, 0);
    check(1, 1, SLL, 2);
    check(1, 2, SLT, 1);
    check($unsigned(-1), 2, SLT, 1);
    check(1, 2, SLTU, 1);
    check(32'b1 << (WIDTH - 1), WIDTH - 1, SRL, 1);
end

endmodule
