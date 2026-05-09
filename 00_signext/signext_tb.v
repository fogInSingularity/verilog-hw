`timescale 1ns/1ps

module signext_tb;

localparam N_TESTS = 10;

localparam N = 20;
localparam M = 32;

reg [N-1 : 0] val;
reg [M-1 : 0] ext;
reg [M-1 : 0] correct;

signext #(
    .N(N),
    .M(M),
    .BEHAVIORAL(1)
) dut (
    .i_val(val),
    .o_ext(ext)
);

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
end

initial begin
    #1

    for (int i = 0; i < N_TESTS; i = i + 1) begin 
        val <= $urandom;
        #1
        correct <= $signed(val);
        #1

        if (ext != correct)
            $display("[FAIL]: val: %h, ext: %h, correct: %h", val, ext, correct);
        else 
            $display("[PASS]: val: %h, ext: %h, correct: %h", val, ext, correct);
    end
end

endmodule
