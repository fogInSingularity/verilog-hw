`include "rv32i.vh"

module dmem #(
    parameter ADDRW = `DATA_MEM_ADDRW,
    parameter DATAW = `DATA_MEMW,
    parameter MASKW = `LSU_MASKW
) (
    input wire clk,
    input wire rst_n,

    input wire                i_wr_en,
    input wire [MASKW-1 : 0]  i_wr_mask,

    input wire [ADDRW-1 : 0]  i_addr,
    input wire [DATAW-1 : 0]  i_wr_data,
    output wire [DATAW-1 : 0] o_rd_data
);

localparam DEPTH = 1 << ADDRW; 

`ifdef ICARUS_SIM

reg [DATAW-1 : 0] mem [DEPTH-1 : 0];

genvar i;
generate
    for (i = 0; i < MASKW; i = i + 1) begin : gen__masked_write
        always @(posedge clk) begin
            if (i_wr_en && i_wr_mask[i]) begin
                mem[i_addr][`BYTEW*(i+1)-1 : `BYTEW*i]
                    <= i_wr_data[`BYTEW*(i+1)-1 : `BYTEW*i];
            end
        end
    end
endgenerate

reg [DATAW-1 : 0] rd_data;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_data <= 0;
    end else begin
        rd_data <= mem[i_addr];
    end
end

assign o_rd_data = rd_data;

`elsif QUARTUS_SYN

dmem_1rw_256x32 dmem_1rw_256x32_inst (
    .address    (i_addr ),
    .byteena    (i_wr_mask ),
    .clock      (clk    ),
    .data       (i_wr_data ),
    .wren       (i_wr_en   ),
    .q          (o_rd_data )
);

`endif


endmodule
