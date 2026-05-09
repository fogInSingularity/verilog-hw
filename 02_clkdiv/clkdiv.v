module clkdiv #(
    parameter BASE_FREQ = 2,
    parameter DIV_FREQ = 1
)(
    input wire rst_n,

    input wire i_clk,
    output reg o_clk
);

localparam RATIO = BASE_FREQ / DIV_FREQ;
localparam CNT_WIDTH = $clog2(RATIO);

// -1 +1
reg [CNT_WIDTH : 0] cnt;

generate
if (RATIO == 1) begin
    always @(*) begin
        o_clk = i_clk;
    end
end else begin
    always @(posedge i_clk or negedge rst_n) begin
        if (!rst_n) begin
            o_clk <= 1'b0;
            cnt <= 0;
        end else begin 
            if (cnt >= RATIO - 1) begin
                cnt <= 0;
                o_clk <= 1'b1;
            end else begin
                cnt <= cnt + 1'b1;
                o_clk <= 0;
            end
        end
    end
end
endgenerate

endmodule
