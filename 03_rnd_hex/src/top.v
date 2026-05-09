module top #(
    parameter DISPLAY_DATAW = 16,
    parameter DISPLAY_SEGMENTSW = 8,
    parameter DISPLAY_ANODESW = 4
) (
    input wire clk,
    input wire rst_n,

    output wire  [DISPLAY_ANODESW-1:0]   o_display_anodes,
    output wire  [DISPLAY_SEGMENTSW-1:0] o_display_segments
);

wire display_clk;

clkdiv #(
    .BASE_FREQ(50_000_000),
    .DIV_FREQ(1)
) div (
    .rst_n(rst_n),
    .i_clk(clk),
    .o_clk(display_clk)
);

localparam DATAW = 16;
wire [DATAW-1 : 0] rng;

lfsr #(
    .WIDTH(DATAW),
    .MASK(16'hD008)
) lfsr_inst (
    .clk(display_clk),
    .rst_n(rst_n),
    .i_en(1'b1),
    .o_value(rng)
);

display display(
    .clk(clk), 
    .rst_n(rst_n), 
    
    .i_data(rng),
    .i_dots(4'b0000),
    .o_anodes(o_display_anodes), 
    .o_segments(o_display_segments)
);

endmodule
