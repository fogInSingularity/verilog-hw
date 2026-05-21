module mux4 #(
    parameter WIDTH = 8
) (
    input wire [WIDTH-1:0] i_val0,
    input wire [WIDTH-1:0] i_val1,
    input wire [WIDTH-1:0] i_val2,
    input wire [WIDTH-1:0] i_val3,
    input wire [1:0]       i_sel,
    output reg [WIDTH-1:0] o_res
);

always @(*) begin
    case (i_sel)
        2'b00: o_res = i_val0;
        2'b01: o_res = i_val1;
        2'b10: o_res = i_val2;
        2'b11: o_res = i_val3;
        default: o_res = {WIDTH{1'bx}};
    endcase
end

endmodule