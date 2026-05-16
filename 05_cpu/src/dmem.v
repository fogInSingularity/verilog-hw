`include "rv32i.vh"

module dmem #(
    parameter ADDRW = `DATA_MEM_ADDRW,
    parameter DATAW = `DATA_MEMW,
    parameter MASKW = `LSU_MASKW
) (
    input wire clk,

    input wire                i_wr_en,
    input wire [MASKW-1 : 0]  i_wr_mask,

    input wire [ADDRW-1 : 0]  i_addr,
    input wire [DATAW-1 : 0]  i_wr_data,
    output wire [DATAW-1 : 0] o_rd_data
);

localparam DEPTH = 1 << ADDRW; 

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

assign o_rd_data = mem[i_addr];

endmodule
