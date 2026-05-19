module stall #(
    parameter DATAW = 1,
    parameter STALL = 1
) (
    input wire clk,
    input wire rst_n,

    input wire [DATAW-1 : 0] i_data,
    output reg [DATAW-1 : 0] o_data
);

generate
if (STALL == 0) begin
    
    always @(*) begin
        o_data = i_data;
    end

end else if (STALL == 1) begin

    always @(posedge clk or negedge rst_n) begin
        o_data <= (!rst_n)
            ? {DATAW{1'b0}}
            : i_data;
    end

end else begin

    localparam STALLS_CNT = STALL - 1;
    reg [STALLS_CNT*DATAW-1 : 0] stalls;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stalls <= {STALLS_CNT*DATAW{1'b0}};
            o_data <= {DATAW{1'b0}};
        end else begin
            {o_data, stalls} <= {stalls, i_data};
        end
    end
    
end
endgenerate


endmodule