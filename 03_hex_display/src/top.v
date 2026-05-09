module top #(
    parameter DISPLAY_DATAW = 16,
    parameter DISPLAY_SEGMENTSW = 8,
    parameter DISPLAY_ANODESW = 4
) (
    input wire clk,
    input wire rst_n,

    input wire   [DISPLAY_DATAW-1 : 0]   i_display_data,
    output wire  [DISPLAY_ANODESW-1:0]   o_display_anodes,
    output wire  [DISPLAY_SEGMENTSW-1:0] o_display_segments
);

display display(
    .clk(clk), 
    .rst_n(rst_n), 
    
    .i_data(i_display_data), 
    .o_anodes(o_display_anodes), 
    .o_segments(o_display_segments)
);

endmodule