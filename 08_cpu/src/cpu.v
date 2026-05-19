`include "rv32i.vh"

module cpu #(
    parameter DISPLAYW = 16
) (
    input wire clk,
    input wire rst_n,

    // mmio

    output wire [DISPLAYW-1 : 0] o_display_data
);

wire [`INST_MEM_ADDRW-1 : 0] imem_addr;
wire [`INST_MEMW-1 : 0]      imem_data;

wire                         xbar_wr_en;
wire [`LSU_MASKW-1 : 0]      xbar_wr_mask;

wire [`REGW-1 : 0]           xbar_addr;
wire [`DATA_MEMW-1 : 0]      xbar_wr_data;
wire [`DATA_MEMW-1 : 0]      xbar_rd_data;

core core_inst (
    .clk(clk),
    .rst_n(rst_n),

    // imem

    .o_imem_addr(imem_addr),
    .i_imem_inst(imem_data),

    // xbar

    .o_xbar_wr_en(xbar_wr_en),
    .o_xbar_wr_mask(xbar_wr_mask),

    .o_xbar_addr(xbar_addr),
    .o_xbar_wr_data(xbar_wr_data),
    .i_xbar_rd_data(xbar_rd_data)
);

imem imem_inst (
    .clk(clk),
    .rst_n(rst_n),

    .i_addr(imem_addr),
    .o_data(imem_data)
);

wire                         dmem_wr_en;
wire [`LSU_MASKW-1 : 0]      dmem_wr_mask;
wire [`DATA_MEM_ADDRW-1 : 0] dmem_addr;
wire [`DATA_MEMW-1 : 0]      dmem_wr_data;
wire [`DATA_MEMW-1 : 0]      dmem_rd_data;

wire                         mmio_wr_en;
wire [`LSU_MASKW-1 : 0]      mmio_wr_mask;
wire [`REGW-1 : 0]           mmio_addr;
wire [`DATA_MEMW-1 : 0]      mmio_wr_data;
wire [`DATA_MEMW-1 : 0]      mmio_rd_data;

mem_xbar mem_xbar_inst (
    .clk(clk),
    .rst_n(rst_n),


    // core
    .i_wr_en(xbar_wr_en),
    .i_wr_mask(xbar_wr_mask),

    .i_addr(xbar_addr),
    .i_wr_data(xbar_wr_data),
    .o_rd_data(xbar_rd_data),

    // dmem
    .o_dmem_wr_en(dmem_wr_en),
    .o_dmem_wr_mask(dmem_wr_mask),

    .o_dmem_addr(dmem_addr),
    .o_dmem_wr_data(dmem_wr_data),
    .i_dmem_rd_data(dmem_rd_data),

    // mmio
    .o_mmio_wr_en(mmio_wr_en),
    .o_mmio_wr_mask(mmio_wr_mask),

    .o_mmio_addr(mmio_addr),
    .o_mmio_wr_data(mmio_wr_data),
    .i_mmio_rd_data(mmio_rd_data)
);

mmio_xbar mmio_xbar_inst (
    .clk(clk),
    .rst_n(rst_n),

    .i_wr_en(mmio_wr_en),
    .i_wr_mask(mmio_wr_mask),

    .i_addr(mmio_addr),
    .i_wr_data(mmio_wr_data),
    .o_rd_data(mmio_rd_data),

    .o_display_data(o_display_data)
);

dmem dmem_inst (
    .clk(clk),
    .rst_n(rst_n),

    .i_wr_en(dmem_wr_en),
    .i_wr_mask(dmem_wr_mask),

    .i_addr(dmem_addr),
    .i_wr_data(dmem_wr_data),
    .o_rd_data(dmem_rd_data)
);

endmodule
