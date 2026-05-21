module fp16_mul #(
    parameter EXP_WIDTH = 5,
    parameter MANT_WIDTH = 10,
    parameter WIDTH = 1 + EXP_WIDTH + MANT_WIDTH,
    parameter BIAS = (6'b1 << (EXP_WIDTH - 1)) - 1
)(
    input wire [WIDTH-1 : 0] i_a,
    input wire [WIDTH-1 : 0] i_b,
    output wire [WIDTH-1 : 0] o_res
);

localparam [EXP_WIDTH-1 : 0] EXP_ZERO = {EXP_WIDTH{1'b0}};
localparam [MANT_WIDTH-1 : 0] MANT_ZERO = {MANT_WIDTH{1'b0}};
localparam [MANT_WIDTH : 0] EXT_MANT_ZERO = {MANT_WIDTH+1{1'b0}};

wire signbit1;
wire [EXP_WIDTH-1+1 : 0] exp1; // +1 to prevent overflow
wire [MANT_WIDTH-1 : 0] mant1;

assign signbit1 = i_a[WIDTH-1];
assign exp1 = i_a[WIDTH-2 : MANT_WIDTH];
assign mant1 = i_a[MANT_WIDTH-1 : 0];

wire is_subnormal1;
assign is_subnormal1 = (exp1 == EXP_ZERO) && (mant1 != MANT_ZERO);
wire is_zero1;
assign is_zero1 = (exp1 == EXP_ZERO) && (mant1 == MANT_ZERO);

wire [MANT_WIDTH-1+1 : 0] full_mant1;
assign full_mant1 = (is_subnormal1 || is_zero1) ? EXT_MANT_ZERO : {1'b1, mant1};

wire signbit2;
wire [EXP_WIDTH-1+1 : 0] exp2;
wire [MANT_WIDTH-1 : 0] mant2;

assign signbit2 = i_b[WIDTH-1];
assign exp2 = i_b[WIDTH-2 : MANT_WIDTH];
assign mant2 = i_b[MANT_WIDTH-1 : 0];

wire is_subnormal2;
assign is_subnormal2 = (exp2 == EXP_ZERO) && (mant2 != MANT_ZERO);
wire is_zero2;
assign is_zero2 = (exp2 == EXP_ZERO) && (mant2 == MANT_ZERO);

wire [MANT_WIDTH-1+1 : 0] full_mant2;
assign full_mant2 = (is_subnormal2 || is_zero2) ? EXT_MANT_ZERO : {1'b1, mant2};

wire signbit_res;
wire [EXP_WIDTH-1+1 : 0] exp_res;
wire [2 * (MANT_WIDTH+1)-1 : 0] full_mant_res;

assign signbit_res = signbit1 ^ signbit2;
assign full_mant_res = $unsigned(full_mant1) * $unsigned(full_mant2);
assign exp_res = exp1 + exp2 - BIAS;

wire [EXP_WIDTH-1 : 0] norm_exp;
wire [2 * (MANT_WIDTH+1)-1 : 0] norm_mant;
assign norm_exp  = (full_mant_res[2 * (MANT_WIDTH+1)-1] == 1'b1) ? exp_res + 1        : exp_res;
assign norm_mant = (full_mant_res[2 * (MANT_WIDTH+1)-1] == 1'b1) ? full_mant_res >> 1 : full_mant_res;

wire [MANT_WIDTH-1 : 0] mant_round;
assign mant_round = norm_mant[2 * MANT_WIDTH : MANT_WIDTH];

wire is_subnormal_res;
assign is_subnormal_res = (norm_exp == EXP_ZERO) && (mant_round != MANT_ZERO);

assign o_res = {
    signbit_res, 
    norm_exp,
    (!is_subnormal_res) ? mant_round : MANT_ZERO
};

endmodule 
