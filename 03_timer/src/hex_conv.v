module hex_conv #(
    parameter DATAW = 12,
    parameter RESW = DATAW * 2
) (
    input wire [DATAW-1 : 0] i_hex,
    output wire [RESW-1 : 0] o_dec
);

localparam DIGITW = 4;
localparam DIGITS = DATAW / DIGITW;

reg [DATAW + RESW - 1 : 0] conv;

integer iter;
integer digit;

reg [DIGITW-1 : 0] digit_data;
reg [RESW-1 : 0] res;

always @(*) begin
    conv = {{RESW{1'b0}}, i_hex};
    for (iter = 0; iter < DATAW; iter = iter + 1) begin
        for (digit = 0; digit < DIGITS; digit = digit + 1) begin
            digit_data = conv[DATAW + DIGITW * digit +: DIGITW];
            if (digit_data >= 4'd5) begin
                conv[DATAW + DIGITW * digit +: DIGITW] = digit_data + 4'd3;
            end
        end

        conv = conv << 1;
    end

    res = conv[DATAW + RESW - 1 : DATAW];
end

assign o_dec = res;

endmodule