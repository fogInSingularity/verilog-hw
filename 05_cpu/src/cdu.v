`include "rv32i.vh"

// control/decode unit
module cdu #(
    parameter INSTW = `INST_MEMW
) (
    input wire [INSTW-1 : 0] i_inst,

    output wire [`ALU_OPS_WIDTH-1 : 0] o_alu_op,
    output wire [`ALU_SELW-1 : 0] o_alu_arg_sel1,
    output wire [`ALU_SELW-1 : 0] o_alu_arg_sel2,

    output wire [`CMP_OPS_WIDTH-1 : 0] o_cmp_op,
    output wire o_is_branch,
    output wire o_is_jump,
    
    output wire [`REGW-1 : 0] o_u_imm,
    output wire [`REGW-1 : 0] o_b_imm,
    output wire [`REGW-1 : 0] o_j_imm,
    output wire [`REGW-1 : 0] o_i_imm,
    output wire [`REGW-1 : 0] o_s_imm,

    output wire [`REG_ADDRW-1 : 0] o_rf_rs1,
    output wire [`REG_ADDRW-1 : 0] o_rf_rs2,
    output wire                    o_rf_rd_we,
    output wire [`REG_ADDRW-1 : 0] o_rf_rd,

    output wire [`WB_SELW-1 : 0] o_wb_sel,

    output wire [`LSU_SELW-1 : 0] o_lsu_inst_type,
    output wire [`LSU_MASKW-1 : 0] o_lsu_mask
);

`define OPCODEW 7
`define FUNC3W  3
`define FUNC7W  7

`define OPCODE_LOAD   7'b0000011
`define OPCODE_OP_IMM 7'b0010011
`define OPCODE_AUIPC  7'b0010111
`define OPCODE_STORE  7'b0100011
`define OPCODE_OP     7'b0110011
`define OPCODE_LUI    7'b0110111
`define OPCODE_BRANCH 7'b1100011
`define OPCODE_JALR   7'b1100111
`define OPCODE_JAL    7'b1101111

`define F3_ADD_SUB 3'b000
`define F3_SLL     3'b001
`define F3_SLT     3'b010
`define F3_SLTU    3'b011
`define F3_XOR     3'b100
`define F3_SRL_SRA 3'b101
`define F3_OR      3'b110
`define F3_AND     3'b111

`define F7_BASE 7'b0000000
`define F7_ALT  7'b0100000

wire [`OPCODEW-1 : 0] opcode = i_inst[6 : 0];
wire [`FUNC3W-1 : 0]  funct3 = i_inst[14 : 12];
wire [`FUNC7W-1 : 0]  funct7 = i_inst[31 : 25];

wire [11 : 0] i_imm_raw;
wire [11 : 0] s_imm_raw;
wire [12 : 0] b_imm_raw;
wire [20 : 0] j_imm_raw;

wire signed [`REGW-1 : 0] i_imm_byte;
wire signed [`REGW-1 : 0] s_imm_byte;
wire signed [`REGW-1 : 0] b_imm_byte;
wire signed [`REGW-1 : 0] j_imm_byte;

assign i_imm_raw = i_inst[31 : 20];
assign s_imm_raw = {i_inst[31 : 25], i_inst[11 : 7]};
assign b_imm_raw = {i_inst[31], i_inst[7], i_inst[30 : 25], i_inst[11 : 8], 1'b0};
assign j_imm_raw = {i_inst[31], i_inst[19 : 12], i_inst[20], i_inst[30 : 21], 1'b0};

signext #(
    .N(12),
    .M(`REGW)
) i_imm_signext (
    .i_val(i_imm_raw),
    .o_ext(i_imm_byte)
);

signext #(
    .N(12),
    .M(`REGW)
) s_imm_signext (
    .i_val(s_imm_raw),
    .o_ext(s_imm_byte)
);

signext #(
    .N(13),
    .M(`REGW)
) b_imm_signext (
    .i_val(b_imm_raw),
    .o_ext(b_imm_byte)
);

signext #(
    .N(21),
    .M(`REGW)
) j_imm_signext (
    .i_val(j_imm_raw),
    .o_ext(j_imm_byte)
);

reg [`ALU_OPS_WIDTH-1 : 0] alu_op;
reg [`ALU_SELW-1 : 0] alu_arg_sel1;
reg [`ALU_SELW-1 : 0] alu_arg_sel2;
reg [`CMP_OPS_WIDTH-1 : 0] cmp_op;
reg is_branch;
reg is_jump;
reg rf_rd_we;
reg [`WB_SELW-1 : 0] wb_sel;
reg [`LSU_SELW-1 : 0] lsu_inst_type;
reg [`LSU_MASKW-1 : 0] lsu_mask;

assign o_rf_rd = i_inst[11 : 7];
assign o_rf_rs1 = i_inst[19 : 15];
assign o_rf_rs2 = i_inst[24 : 20];

assign o_u_imm = {i_inst[31 : 12], 12'b0};
assign o_i_imm = i_imm_byte;
assign o_s_imm = s_imm_byte;
assign o_b_imm = $signed(b_imm_byte) >>> 2;
assign o_j_imm = $signed(j_imm_byte) >>> 2;

assign o_alu_op = alu_op;
assign o_alu_arg_sel1 = alu_arg_sel1;
assign o_alu_arg_sel2 = alu_arg_sel2;
assign o_cmp_op = cmp_op;
assign o_is_branch = is_branch;
assign o_is_jump = is_jump;
assign o_rf_rd_we = rf_rd_we;
assign o_wb_sel = wb_sel;
assign o_lsu_inst_type = lsu_inst_type;
assign o_lsu_mask = lsu_mask;

always @(*) begin
    alu_op = {`ALU_OPS_WIDTH{1'bx}};
    alu_arg_sel1 = {`ALU_SELW{1'bx}};
    alu_arg_sel2 = {`ALU_SELW{1'bx}};
    cmp_op = {`CMP_OPS_WIDTH{1'bx}};
    is_branch = 1'b0;
    is_jump = 1'b0;
    rf_rd_we = 1'b0;
    wb_sel = {`WB_SELW{1'bx}};
    lsu_inst_type = `INST_LOAD;
    lsu_mask = 4'b0000;

    case (opcode)
        `OPCODE_LUI: begin
            rf_rd_we = 1'b1;
            wb_sel = `WB_SEL_UIMM;
        end

        `OPCODE_AUIPC: begin
            alu_op = `ADD;
            alu_arg_sel1 = `SEL1_UIMM;
            alu_arg_sel2 = `SEL2_PC;
            rf_rd_we = 1'b1;
            wb_sel = `WB_SEL_ALU;
        end

        `OPCODE_JAL: begin
            alu_op = `ADD;
            alu_arg_sel1 = `SEL1_JIMM;
            alu_arg_sel2 = `SEL2_PC;
            is_jump = 1'b1;
            rf_rd_we = 1'b1;
            wb_sel = `WB_SEL_PC_INC;
        end

        `OPCODE_JALR: begin
            alu_op = `ADD;
            alu_arg_sel1 = `SEL1_RF_SRC1;
            alu_arg_sel2 = `SEL2_IIMM;
            is_jump = 1'b1;
            rf_rd_we = 1'b1;
            wb_sel = `WB_SEL_PC_INC;
        end

        `OPCODE_BRANCH: begin
            alu_op = `ADD;
            alu_arg_sel1 = `SEL1_BIMM;
            alu_arg_sel2 = `SEL2_PC;
            is_branch = 1'b1;

            case (funct3)
                3'b000: cmp_op = `BEQ;
                3'b001: cmp_op = `BNE;
                3'b100: cmp_op = `BLT;
                3'b101: cmp_op = `BGE;
                3'b110: cmp_op = `BLTU;
                3'b111: cmp_op = `BGEU;
                default: begin
                    is_branch = 1'b0;
                end
            endcase
        end

        `OPCODE_LOAD: begin
            alu_op = `ADD;
            alu_arg_sel1 = `SEL1_RF_SRC1;
            alu_arg_sel2 = `SEL2_IIMM;
            rf_rd_we = 1'b1;
            wb_sel = `WB_SEL_LOAD;
            lsu_inst_type = `INST_LOAD;

            case (funct3)
                3'b000,
                3'b100: lsu_mask = 4'b0001;
                3'b001,
                3'b101: lsu_mask = 4'b0011;
                3'b010: lsu_mask = 4'b1111;
                default: begin
                    rf_rd_we = 1'b0;
                    wb_sel = {`WB_SELW{1'bx}};
                end
            endcase
        end

        `OPCODE_STORE: begin
            alu_op = `ADD;
            alu_arg_sel1 = `SEL1_RF_SRC1;
            alu_arg_sel2 = `SEL2_SIMM;
            lsu_inst_type = `INST_STORE;

            case (funct3)
                3'b000: lsu_mask = 4'b0001;
                3'b001: lsu_mask = 4'b0011;
                3'b010: lsu_mask = 4'b1111;
                default: begin
                    lsu_inst_type = `INST_LOAD;
                end
            endcase
        end

        `OPCODE_OP_IMM: begin
            alu_arg_sel1 = `SEL1_RF_SRC1;
            alu_arg_sel2 = `SEL2_IIMM;
            rf_rd_we = 1'b1;
            wb_sel = `WB_SEL_ALU;

            case (funct3)
                `F3_ADD_SUB: alu_op = `ADD;
                `F3_SLL:     alu_op = `SLL;
                `F3_SLT:     alu_op = `SLT;
                `F3_SLTU:    alu_op = `SLTU;
                `F3_XOR:     alu_op = `XOR;
                `F3_SRL_SRA: alu_op = (funct7 == `F7_ALT) ? `SRA : `SRL;
                `F3_OR:      alu_op = `OR;
                `F3_AND:     alu_op = `AND;
                default: begin
                    rf_rd_we = 1'b0;
                    wb_sel = {`WB_SELW{1'bx}};
                end
            endcase
        end

        `OPCODE_OP: begin
            alu_arg_sel1 = `SEL1_RF_SRC1;
            alu_arg_sel2 = `SEL2_RF_SRC2;
            rf_rd_we = 1'b1;
            wb_sel = `WB_SEL_ALU;

            case (funct3)
                `F3_ADD_SUB: alu_op = (funct7 == `F7_ALT) ? `SUB : `ADD;
                `F3_SLL:     alu_op = `SLL;
                `F3_SLT:     alu_op = `SLT;
                `F3_SLTU:    alu_op = `SLTU;
                `F3_XOR:     alu_op = `XOR;
                `F3_SRL_SRA: alu_op = (funct7 == `F7_ALT) ? `SRA : `SRL;
                `F3_OR:      alu_op = `OR;
                `F3_AND:     alu_op = `AND;
                default: begin
                    rf_rd_we = 1'b0;
                    wb_sel = {`WB_SELW{1'bx}};
                end
            endcase

            if ((funct7 != `F7_BASE) && (funct7 != `F7_ALT)) begin
                rf_rd_we = 1'b0;
                wb_sel = {`WB_SELW{1'bx}};
            end
        end

        default: begin
        end
    endcase
end

endmodule
