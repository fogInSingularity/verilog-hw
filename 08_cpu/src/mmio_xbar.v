`include "rv32i.vh"
`include "mmio_map.vh"

module mmio_xbar #(
    parameter ADDRW = `REGW,
    parameter DATAW = `DATA_MEMW,
    parameter MASKW = `LSU_MASKW,

    parameter DISPLAYW = 16
) (
    input wire clk,
    input wire rst_n,

    input wire                i_wr_en,
    input wire [MASKW-1 : 0]  i_wr_mask,

    input wire [ADDRW-1 : 0]  i_addr,
    input wire [DATAW-1 : 0]  i_wr_data,
    output wire [DATAW-1 : 0] o_rd_data,

    output reg [DISPLAYW-1 : 0] o_display_data
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        o_display_data <= 0;
    end else begin
        if (i_wr_en && (i_addr == `DISPLAY_ADDR)) begin
            o_display_data <= i_wr_data[DISPLAYW-1 : 0];
        end
    end
end

endmodule
