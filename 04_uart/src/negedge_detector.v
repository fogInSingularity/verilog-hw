module negedge_detector (
    input wire clk,
    input wire rst_n,

    input wire i_signal,
    output wire o_edge
);

reg signal_ff;

always @(posedge clk or negedge rst_n) begin
    signal_ff <= (!rst_n)
        ? 1'b0
        : i_signal;
end

assign o_edge = ~i_signal && signal_ff;

endmodule