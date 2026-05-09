module sync_1bit #(
    parameter STAGES = 2,
    parameter INIT_VAL = 1'b0
) (
    input wire clk,
    input wire rst_n,

    input wire i_async,
    output reg o_sync
);

reg [STAGES-2 : 0] sync_stages; // STAGES = sync_stages + o_sync 

always @(posedge clk or negedge rst_n) begin
    {o_sync, sync_stages} <= (!rst_n) 
        ? {(STAGES+1){INIT_VAL}}
        : {sync_stages, i_async};
end

endmodule