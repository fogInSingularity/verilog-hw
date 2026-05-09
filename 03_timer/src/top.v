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

localparam TIME_DATAW = DISPLAY_DATAW;
localparam SECSW = 12;
localparam MSECSW = 4;

wire [TIME_DATAW-1 : 0] time_data;

display display(
    .clk(clk), 
    .rst_n(rst_n), 
    
    .i_data(time_data),
    .i_dots(4'b0010),
    .o_anodes(o_display_anodes), 
    .o_segments(o_display_segments)
);

wire [SECSW-1 : 0] secs;
wire [MSECSW-1 : 0] msecs; 

timer timer_inst(
    .clk(clk),
    .rst_n(rst_n),
    .o_secs(secs),
    .o_msecs(msecs)
);

wire [SECSW-1 : 0] secs_conv;

hex_conv hex_conv_inst(
    .i_hex(secs),
    .o_dec(secs_conv)
);

assign time_data = {secs_conv, msecs};

endmodule
