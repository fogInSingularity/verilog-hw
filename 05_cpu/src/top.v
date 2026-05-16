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

wire [DISPLAY_DATAW-1 : 0] display_data;

display display(
    .clk(clk), 
    .rst_n(rst_n), 
    
    .i_data(display_data), 
    .o_anodes(o_display_anodes), 
    .o_segments(o_display_segments)
);

cpu #(
    .DISPLAYW(DISPLAY_DATAW)
) (
    .clk(clk),
    .rst_n(rst_n),

    .o_display_data(display_data)
);

endmodule