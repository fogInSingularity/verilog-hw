`include "rv32i.vh"

module mem_xbar #(
    parameter ADDRW = `REGW,
    parameter DATAW = `DATA_MEMW,
    parameter MASKW = `LSU_MASKW
) (
    input wire clk,
    input wire rst_n,

    // core
    input wire                i_wr_en,
    input wire [MASKW-1 : 0]  i_wr_mask,

    input wire [ADDRW-1 : 0]  i_addr,
    input wire [DATAW-1 : 0]  i_wr_data,
    output wire [DATAW-1 : 0] o_rd_data,

    // dmem
    output wire               o_dmem_wr_en,
    output wire [MASKW-1 : 0] o_dmem_wr_mask,

    output wire [ADDRW-1 : 0] o_dmem_addr,
    output wire [DATAW-1 : 0] o_dmem_wr_data,
    input wire [DATAW-1 : 0]  i_dmem_rd_data,

    // mmio
    output wire               o_mmio_wr_en,
    output wire [MASKW-1 : 0] o_mmio_wr_mask,

    output wire [ADDRW-1 : 0] o_mmio_addr,
    output wire [DATAW-1 : 0] o_mmio_wr_data,
    input wire [DATAW-1 : 0]  i_mmio_rd_data
);

localparam [0:0] MMIO_SEL = 1'b0, DMEM_SEL = 1'b1;

wire [0:0] xbar_sel;
assign xbar_sel = (i_addr < `DMEM_LOW_ADDR) ? MMIO_SEL : DMEM_SEL;

assign o_dmem_wr_en = i_wr_en && (xbar_sel == DMEM_SEL); 
assign o_mmio_wr_en = i_wr_en && (xbar_sel == MMIO_SEL); 

assign o_dmem_wr_mask = i_wr_mask;
assign o_mmio_wr_mask = i_wr_mask;

assign o_dmem_addr = i_addr >> $clog2(DATAW / 8);
assign o_mmio_addr = i_addr;

assign o_dmem_wr_data = i_wr_data;
assign o_mmio_wr_data = i_wr_data;

wire [0:0] xbar_rd_sel;

stall #( // rd latency - 1
    .DATAW(1),
    .STALL(1)
) stall_sel (
    .clk(clk),
    .rst_n(rst_n),
    .i_data(xbar_sel),
    .o_data(xbar_rd_sel)
);

assign o_rd_data = (xbar_rd_sel == MMIO_SEL) ? i_mmio_rd_data : i_dmem_rd_data;

endmodule
