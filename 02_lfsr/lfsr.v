module lfsr #(
    parameter WIDTH = 8,
    parameter MASK = 8'hB8
) (
    input wire clk,
    input wire rst_n,
    
    input wire i_en,

    output wire [WIDTH-1 : 0] o_value
);

reg [WIDTH-1 : 0] shift;

wire new_bit;
assign new_bit = ^(shift & MASK);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift <= 1;
    end else if (i_en) begin
        shift <= {shift[WIDTH-2:0], new_bit};
    end
end

assign o_value = shift;

endmodule
