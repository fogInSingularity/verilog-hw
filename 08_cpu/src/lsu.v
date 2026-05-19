`include "rv32i.vh"

// load/store unit
module lsu (
    // core

    input wire [`REGW-1 : 0] i_addr,
    input wire [`REGW-1 : 0] i_store_data,
    output wire [`REGW-1 : 0] o_load_data,

    input wire [`LSU_MASKW-1 : 0] i_lsu_mask,
    input wire [`LSU_SELW-1 : 0] i_inst_type,

    // dmem

    output wire                         o_mem_wr_en,
    output wire [`LSU_MASKW-1 : 0]      o_mem_wr_mask,

    output wire [`REGW-1 : 0]           o_mem_addr,
    output wire [`DATA_MEMW-1 : 0]      o_mem_wr_data,
    input wire [`DATA_MEMW-1 : 0]       i_mem_rd_data
);

assign o_mem_wr_en = (i_inst_type == `INST_LSU_STORE);
assign o_mem_wr_mask = o_mem_wr_en ? i_lsu_mask : `LSU_MASKW'b0;

assign o_mem_addr = i_addr;
assign o_mem_wr_data = i_store_data;
assign o_load_data = i_mem_rd_data;

endmodule
