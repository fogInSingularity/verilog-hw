module display #(
    parameter NUMW = 4,
    parameter DISPLAYW = 4,
    parameter DATAW = NUMW * DISPLAYW,
    parameter SEGMENTSW = 8
) (
    input  wire clk,
    input  wire rst_n,
   
    input  wire [DATAW-1 : 0]    i_data,
    input  wire [DISPLAYW-1 : 0] i_dots,
    output wire [DISPLAYW-1:0]   o_anodes,
    output wire  [SEGMENTSW-1:0]  o_segments
);

localparam POSW = $clog2(DISPLAYW);
localparam CLKDIVW = 14;
reg [CLKDIVW-1 : 0] cnt;
wire [POSW-1:0] pos = cnt[CLKDIVW-1 : CLKDIVW-POSW];
wire [NUMW-1 : 0] digit;

wire [DATAW-1 : 0] masked_data;
assign masked_data = (i_data >> (pos * NUMW)) & 4'hf;

assign digit = masked_data[NUMW-1 : 0];

// clkdiv
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt <= 14'b0;
    else        cnt <= cnt + 1'b1;
end

assign o_anodes = ~(4'b1 << pos);

reg [SEGMENTSW-2 : 0] digit_conv;

always @(*) begin
    case (digit)
        4'h0:    digit_conv = 7'b1111110;
        4'h1:    digit_conv = 7'b0110000;
        4'h2:    digit_conv = 7'b1101101;
        4'h3:    digit_conv = 7'b1111001;
        4'h4:    digit_conv = 7'b0110011;
        4'h5:    digit_conv = 7'b1011011;
        4'h6:    digit_conv = 7'b1011111;
        4'h7:    digit_conv = 7'b1110000;
        4'h8:    digit_conv = 7'b1111111;
        4'h9:    digit_conv = 7'b1111011;
        4'hA:    digit_conv = 7'b1110111;
        4'hb:    digit_conv = 7'b0011111;
        4'hC:    digit_conv = 7'b1001110;
        4'hd:    digit_conv = 7'b0111101;
        4'hE:    digit_conv = 7'b1001111;
        4'hF:    digit_conv = 7'b1000111;
        default: digit_conv = 7'b0000000;
    endcase
end

wire dot;
assign dot = (i_dots >> pos) & 1'b1;

assign o_segments = {digit_conv, dot};

endmodule
