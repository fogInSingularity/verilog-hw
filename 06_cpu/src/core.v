`include "rv32i.vh"

module core (
    input wire clk,
    input wire rst_n,

    // imem

    output wire [`INST_MEM_ADDRW-1 : 0] o_imem_addr,
    input wire [`INST_MEMW-1 : 0]       i_imem_inst,

    // mem xbar

    output wire                         o_xbar_wr_en,
    output wire [`LSU_MASKW-1 : 0]      o_xbar_wr_mask,

    output wire [`REGW-1 : 0]           o_xbar_addr,
    output wire [`DATA_MEMW-1 : 0]      o_xbar_wr_data,
    input wire [`DATA_MEMW-1 : 0]       i_xbar_rd_data
);

reg [`PCW-1 : 0] pc;
wire [`PCW-1 : 0] pc_inc;
reg [`PCW-1 : 0] pc_next;
assign pc_inc = pc + `PC_INC_VAL;

wire [`PCW-1 : 0] pc_branch;

wire taken;
wire hold_pc;

always @(*) begin
    casez ({hold_pc, taken}) 
        2'b1?:   pc_next = pc;
        2'b00:   pc_next = pc_inc;
        2'b01:   pc_next = pc_branch; 
        default: pc_next = `PCW'bx;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= `PC_INIT_VAL;
    end else begin
        pc <= pc_next;
    end
end

assign o_imem_addr = pc_next >> 2;

wire [`ALU_OPS_WIDTH-1 : 0] alu_op;
wire [`ALU_SELW-1 : 0] alu_sel1;
wire [`ALU_SELW-1 : 0] alu_sel2;

wire [`CMP_OPS_WIDTH-1 : 0] jbt_op;
wire is_branch;
wire is_jump;

wire [`REGW-1 : 0] inst_u_imm;
wire [`REGW-1 : 0] inst_b_imm;
wire [`REGW-1 : 0] inst_j_imm;
wire [`REGW-1 : 0] inst_i_imm;
wire [`REGW-1 : 0] inst_s_imm;

wire [`REG_ADDRW-1 : 0] rf_rs1;
wire [`REG_ADDRW-1 : 0] rf_rs2;
wire [`REG_ADDRW-1 : 0] rf_rd;

wire [`REGW-1 : 0] rf_src1;
wire [`REGW-1 : 0] rf_src2;
wire               rf_rd_we;
reg [`REGW-1 : 0]  rf_dest;

wire [`WB_SELW-1 : 0] wb_sel;

wire [`LSU_SELW-1 : 0] lsu_inst_type;
wire [`LSU_MASKW-1 : 0] lsu_mask;

cdu cdu_inst (
    .i_inst(i_imem_inst),

    .o_alu_op(alu_op),
    .o_alu_arg_sel1(alu_sel1),
    .o_alu_arg_sel2(alu_sel2),

    .o_cmp_op(jbt_op),
    .o_is_branch(is_branch),
    .o_is_jump(is_jump),

    .o_u_imm(inst_u_imm),
    .o_b_imm(inst_b_imm),
    .o_j_imm(inst_j_imm),
    .o_i_imm(inst_i_imm),
    .o_s_imm(inst_s_imm),

    .o_rf_rs1(rf_rs1),
    .o_rf_rs2(rf_rs2),
    .o_rf_rd_we(rf_rd_we),
    .o_rf_rd(rf_rd),

    .o_wb_sel(wb_sel),

    .o_lsu_inst_type(lsu_inst_type),
    .o_lsu_mask(lsu_mask)
);

reg mem_load_hold;
assign hold_pc = ((lsu_inst_type == `INST_LSU_LOAD) && ~mem_load_hold);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_load_hold <= 1;
    end else begin
        mem_load_hold <= hold_pc;
    end
end

regfile #(
    .MEM_DEPTH(`N_REGS),
    .MEM_WIDTH(`REGW),
    .IS_COMB_RD(1'b1)
) regfile (
    .clk(clk),

    .i_we(rf_rd_we),
    .i_waddr(rf_rd),
    .i_wdata(rf_dest),

    .i_raddr_a(rf_rs1),
    .o_rdata_a(rf_src1),

    .i_raddr_b(rf_rs2),
    .o_rdata_b(rf_src2)
);

reg [`REGW-1 : 0] alu_src1;
reg [`REGW-1 : 0] alu_src2;
wire [`REGW-1 : 0] alu_dest;

always @(*) begin
    case (alu_sel1) 
        `SEL1_UIMM:    alu_src1 = inst_u_imm;
        `SEL1_BIMM:    alu_src1 = inst_b_imm;
        `SEL1_JIMM:    alu_src1 = inst_j_imm;
        `SEL1_RF_SRC1: alu_src1 = rf_src1;
    endcase
end

always @(*) begin
    case (alu_sel2) 
        `SEL2_RF_SRC2: alu_src2 = rf_src2;
        `SEL2_IIMM:    alu_src2 = inst_i_imm;
        `SEL2_SIMM:    alu_src2 = inst_s_imm;
        `SEL2_PC:      alu_src2 = pc;
    endcase
end

alu alu_inst (
    .i_oprd1(alu_src1),
    .i_oprd2(alu_src2),
    .o_res(alu_dest),

    .i_sel(alu_op)
);

wire [`REGW-1 : 0] load_data;

lsu lsu_inst (
    // core
    .i_addr(alu_dest),
    .i_store_data(rf_src2),
    .o_load_data(load_data),

    .i_lsu_mask(lsu_mask),
    .i_inst_type(lsu_inst_type),

    // memory
    .o_mem_wr_en(o_xbar_wr_en),
    .o_mem_wr_mask(o_xbar_wr_mask),

    .o_mem_addr(o_xbar_addr),
    .o_mem_wr_data(o_xbar_wr_data),
    .i_mem_rd_data(i_xbar_rd_data)
);

always @(*) begin
    case (wb_sel)
        `WB_SEL_UIMM:   rf_dest = inst_u_imm;
        `WB_SEL_ALU:    rf_dest = alu_dest;
        `WB_SEL_LOAD:   rf_dest = load_data;
        `WB_SEL_PC_INC: rf_dest = pc_inc;
    endcase
end

// jump/branch taken {{{

wire is_jbt_taken;

cmp #(
    .WIDTH(`REGW)
) jbt (
    .i_oprd1(rf_src1),
    .i_oprd2(rf_src2),

    .o_taken(is_jbt_taken),

    .i_sel(jbt_op)
);

assign taken = (is_jbt_taken && is_branch) || is_jump;

assign pc_branch = alu_dest;

// }}} jump/branch taken

endmodule
