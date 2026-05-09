`timescale 1ns/1ps

module shiftreg_ser_tb;

localparam WIDTH = 8;

reg clk;
reg rst_n;

reg en;
reg is_par_load;
reg [WIDTH-1 : 0] par_data;
reg in_ser_data;

wire out_ser_data;

shiftreg #(
    .WIDTH(WIDTH)
) dut (
    .clk(clk),
    .rst_n(rst_n),

    .i_en(en),
    .i_is_par_load(is_par_load),

    .i_par_data(par_data),
    .i_ser_data(in_ser_data),

    .o_ser_data(out_ser_data)
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

    en = '1;
    is_par_load = '1;
    par_data = 8'b10011011;

    @(posedge clk) #1
    is_par_load = '0;
    in_ser_data = '0;

    @(posedge clk) #1
    in_ser_data = '1;

    @(posedge clk) #1
    in_ser_data = '1;

    @(posedge clk) #1
    in_ser_data = '1;

    @(posedge clk) #1
    in_ser_data = '0;

    #300
    $finish();
end

endmodule
