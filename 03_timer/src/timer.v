module timer #(
    parameter SEC_DATAW = 12,
    parameter MSEC_DATAW = 4,
    parameter SECONDS = 12'd60
) (
    input wire clk,
    input wire rst_n,

    output wire [SEC_DATAW-1 : 0]  o_secs,
    output wire [MSEC_DATAW-1 : 0] o_msecs
);

wire timer_clk;

reg [SEC_DATAW-1 : 0]   secs_cnt;
reg [MSEC_DATAW-1 : 0]  msecs_cnt;

clkdiv #(
    .BASE_FREQ(50_000_000),
    .DIV_FREQ(10) // 10 Hz == 0.1 s
) div (
    .rst_n(rst_n),
    .i_clk(clk),
    .o_clk(timer_clk)
);

always @(posedge timer_clk or negedge rst_n) begin
    if (!rst_n) begin
        secs_cnt <= SECONDS;
        msecs_cnt <= 0;
    end else begin
        if (secs_cnt == 0 && msecs_cnt == 0) begin
            secs_cnt <= 0;
            msecs_cnt <= 0;
        end else if (msecs_cnt == 0) begin
            secs_cnt  <= secs_cnt - 1;
            msecs_cnt <= 9;
        end else begin
            msecs_cnt <= msecs_cnt - 1;
        end
    end
end

assign o_secs = secs_cnt;
assign o_msecs = msecs_cnt;

endmodule