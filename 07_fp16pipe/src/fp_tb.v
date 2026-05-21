`timescale 1ns/10ps

module fp_tb;

localparam LATENCY = `LATENCY - 1;
localparam REF_LATENCY = (LATENCY == 0) ? 0 : (LATENCY - 1);

reg clk = 1'b0;
always #1 clk <= ~clk;

reg rst_n = 1'b0;

reg [15:0] a, b;
wire [15:0] c;

reg [3*16-1:0] test [0:`TEST_SIZE-1];

fp_add fp_add_inst (
    .clk   (clk),
    .rst_n (rst_n),
    .i_a   (a),
    .i_b   (b),
    .o_res (c)
);

reg [15:0] a_pipe [0:REF_LATENCY];
reg [15:0] b_pipe [0:REF_LATENCY];
reg [15:0] z_pipe [0:REF_LATENCY];

reg [$clog2(`TEST_SIZE + 32)-1:0] idx = 0;
integer i;

wire [15:0] a_ref = a_pipe[REF_LATENCY];
wire [15:0] b_ref = b_pipe[REF_LATENCY];
wire [15:0] z_ref = z_pipe[REF_LATENCY];

wire       z_sign = z_ref[15];
wire [4:0] z_bexp = z_ref[14:10];
wire [9:0] z_mant = z_ref[9:0];

wire       c_sign = c[15];
wire [4:0] c_bexp = c[14:10];
wire [9:0] c_mant = c[9:0];

wire signed [14:0] diff = $signed(c[14:0]) - $signed(z_ref[14:0]);

reg ok;
reg pass = 1'b1;
wire pass_next = pass & ok;

always @(*) begin
    if (z_bexp == 5'h00)
        ok = (c_bexp == 5'h00) && (c_mant == 10'h000) && (c_sign == z_sign);
    else if (z_bexp == 5'h1F)
        ok = (c_bexp == 5'h1F) && (c_mant == 10'h000) && (c_sign == z_sign);
    else
        ok = ($abs(diff) < 2) && (c_sign == z_sign);
end

wire valid = rst_n && (idx > REF_LATENCY);
wire done  = rst_n && (idx == `TEST_SIZE + REF_LATENCY + 1);

initial begin
    $readmemh("test.txt", test);

    a = 16'h0000;
    b = 16'h0000;

    for (i = 0; i <= REF_LATENCY; i = i + 1) begin
        a_pipe[i] = 16'h0000;
        b_pipe[i] = 16'h0000;
        z_pipe[i] = 16'h0000;
    end

    repeat (2) @(negedge clk);
    rst_n = 1'b1;
end

always @(negedge clk) begin
    if (rst_n) begin
        if (valid) begin
            if (`DEBUG || !ok) begin
                $display("[%d] %h %h -> %h z=%h ok=%d",
                         idx - REF_LATENCY - 1, a_ref, b_ref, c, z_ref, ok);
            end

            pass <= pass_next;
        end

        if (done) begin
            $display("Result: %s", pass ? "PASS" : "FAIL");
            $finish;
        end

        if (idx < `TEST_SIZE) begin
            a <= test[idx][47:32];
            b <= test[idx][31:16];

            a_pipe[0] <= test[idx][47:32];
            b_pipe[0] <= test[idx][31:16];
            z_pipe[0] <= test[idx][15:0];
        end else begin
            a <= 16'h0000;
            b <= 16'h0000;

            a_pipe[0] <= 16'h0000;
            b_pipe[0] <= 16'h0000;
            z_pipe[0] <= 16'h0000;
        end

        for (i = 1; i <= REF_LATENCY; i = i + 1) begin
            a_pipe[i] <= a_pipe[i-1];
            b_pipe[i] <= b_pipe[i-1];
            z_pipe[i] <= z_pipe[i-1];
        end

        idx <= idx + 1'b1;
    end
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, fp_tb);

    $display("Test size: %d", `TEST_SIZE);
    $display("Latency:   %d", LATENCY);
    $display("Ref pipe:  %d", REF_LATENCY);
end

endmodule