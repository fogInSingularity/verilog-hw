module shiftreg #(
    parameter WIDTH = 8
) (
    input wire clk,
    input wire rst_n,

    input wire i_en,
    input wire i_is_par_load,

    input wire [WIDTH-1 : 0] i_par_data,
    input wire i_ser_data,

    output reg o_ser_data
);

reg [WIDTH-1 : 0] shift;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift <= '0;
    end else if (i_en) begin
        o_ser_data <= shift[WIDTH-1];
        if (i_is_par_load) begin
            shift <= i_par_data;
        end else begin
            shift[0] <= i_ser_data;
            shift[WIDTH-1 : 1] <= {shift[WIDTH-2:0]};
        end
    end
end

endmodule
