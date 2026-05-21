module add_1st #(
    parameter EXP_WIDTH = 5,
    parameter MANT_WIDTH = 10,
    parameter WIDTH = 1 + EXP_WIDTH + MANT_WIDTH,
    parameter BIAS = (6'b1 << (EXP_WIDTH - 1)) - 1
) (
    input wire clk,
    input wire rst_n,

    input wire [WIDTH-1 : 0] i_a,
    input wire [WIDTH-1 : 0] i_b,
    output wire [WIDTH-1 : 0] o_res
);

localparam [EXP_WIDTH-1 : 0] EXP_ZERO = {EXP_WIDTH{1'b0}};
localparam [EXP_WIDTH : 0] EXT_EXP_ZERO = {EXP_WIDTH+1{1'b0}};
localparam [MANT_WIDTH-1 : 0] MANT_ZERO = {MANT_WIDTH{1'b0}};
localparam [MANT_WIDTH : 0] EXT_MANT_ZERO = {MANT_WIDTH+1{1'b0}};

// unpack {{{

wire signbit1;
wire [EXP_WIDTH-1+1 : 0] exp1; // +1 to prevent overflow
wire [MANT_WIDTH-1 : 0] mant1;

assign signbit1 = i_a[WIDTH-1];
assign exp1 = i_a[WIDTH-2 : MANT_WIDTH];
assign mant1 = i_a[MANT_WIDTH-1 : 0];

wire is_subnormal1;
assign is_subnormal1 = (exp1 == {1'b0, EXP_ZERO}) && (mant1 != MANT_ZERO);
wire is_zero1;
assign is_zero1 = (exp1 == {1'b0, EXP_ZERO}) && (mant1 == MANT_ZERO);

wire [MANT_WIDTH-1+1 : 0] full_mant1;
assign full_mant1 = (is_subnormal1 || is_zero1) ? EXT_MANT_ZERO : {1'b1, mant1};

wire signbit2;
wire [EXP_WIDTH-1+1 : 0] exp2;
wire [MANT_WIDTH-1 : 0] mant2;

assign signbit2 = i_b[WIDTH-1];
assign exp2 = i_b[WIDTH-2 : MANT_WIDTH];
assign mant2 = i_b[MANT_WIDTH-1 : 0];

wire is_subnormal2;
assign is_subnormal2 = (exp2 == {1'b0, EXP_ZERO}) && (mant2 != MANT_ZERO);
wire is_zero2;
assign is_zero2 = (exp2 == {1'b0, EXP_ZERO}) && (mant2 == MANT_ZERO);

wire [MANT_WIDTH-1+1 : 0] full_mant2;
assign full_mant2 = (is_subnormal2 || is_zero2) ? EXT_MANT_ZERO : {1'b1, mant2};

// }}} unpack

localparam EXTRA_BITS  = 1;
localparam EXTRA_WIDTH = MANT_WIDTH + 1 + EXTRA_BITS; // 12

wire [EXTRA_WIDTH-1 : 0] ext_mant1;
assign ext_mant1 = {full_mant1, {EXTRA_BITS{1'b0}}};

wire [EXTRA_WIDTH-1 : 0] ext_mant2;
assign ext_mant2 = {full_mant2, {EXTRA_BITS{1'b0}}};

// swap {{{

wire mag1_ge_mag2;
assign mag1_ge_mag2 = (exp1 > exp2) || ((exp1 == exp2) && (full_mant1 >= full_mant2));

wire big_sign;
wire small_sign;
wire [EXP_WIDTH : 0] big_exp;
wire [EXP_WIDTH : 0] small_exp;
wire [EXTRA_WIDTH-1 : 0] big_mant;
wire [EXTRA_WIDTH-1 : 0] small_mant;

assign big_sign   = mag1_ge_mag2 ? signbit1  : signbit2;
assign small_sign = mag1_ge_mag2 ? signbit2  : signbit1;
assign big_exp    = mag1_ge_mag2 ? exp1      : exp2;
assign small_exp  = mag1_ge_mag2 ? exp2      : exp1;
assign big_mant   = mag1_ge_mag2 ? ext_mant1 : ext_mant2;
assign small_mant = mag1_ge_mag2 ? ext_mant2 : ext_mant1;

// }}} swap

// exp diff {{{

wire [EXP_WIDTH : 0] exp_diff;
assign exp_diff = big_exp - small_exp;

// }}} exp diff

// shift {{{

wire [EXTRA_WIDTH-1 : 0] small_mant_shifted;
assign small_mant_shifted = small_mant >> exp_diff;

// }}} shift

// sign magnitude adder {{{

wire same_sign;
assign same_sign = (big_sign == small_sign);

wire [EXTRA_WIDTH : 0] addsub_res;
assign addsub_res = same_sign 
    ? ({1'b0, big_mant} + {1'b0, small_mant_shifted}) 
    : ({1'b0, big_mant} - {1'b0, small_mant_shifted});

wire addsub_zero;
assign addsub_zero = (addsub_res == {EXTRA_WIDTH+1{1'b0}});

// }}} sign magnitude adder 

// normalize {{{

reg [EXTRA_WIDTH-1 : 0] norm_mant;
reg [EXP_WIDTH : 0]     norm_exp;

reg [EXP_WIDTH : 0] lz;
reg [EXP_WIDTH : 0] max_shift;
reg [EXP_WIDTH : 0] shift_amt;
reg found_one;

integer idx;

always @(*) begin
    norm_mant = addsub_res[EXTRA_WIDTH-1 : 0];
    norm_exp  = big_exp;

    lz         = {EXP_WIDTH+1{1'b0}};
    max_shift  = {EXP_WIDTH+1{1'b0}};
    shift_amt  = {EXP_WIDTH+1{1'b0}};
    found_one  = 1'b0;

    if (addsub_zero) begin
        norm_mant = {EXTRA_WIDTH{1'b0}};
        norm_exp  = EXT_EXP_ZERO;
    end else if (same_sign && addsub_res[EXTRA_WIDTH]) begin
        norm_mant = addsub_res[EXTRA_WIDTH : 1];
        norm_exp  = big_exp + 1'b1;
    end else begin
        lz = EXTRA_WIDTH;

        for (idx = EXTRA_WIDTH - 1; idx >= 0; idx = idx - 1) begin
            if (!found_one && addsub_res[idx]) begin
                lz = (EXTRA_WIDTH - 1 - idx);
                found_one = 1'b1;
            end
        end

        if (big_exp > 1) max_shift = big_exp - 1'b1;
        else max_shift = {EXP_WIDTH+1{1'b0}};

        if (lz < max_shift) shift_amt = lz;
        else shift_amt = max_shift;

        norm_mant = addsub_res[EXTRA_WIDTH-1 : 0] << shift_amt;
        norm_exp  = big_exp - shift_amt;
    end
end

// }}} normalize

wire [MANT_WIDTH : 0] rounded_mant;
assign rounded_mant = norm_mant[EXTRA_WIDTH-1 : EXTRA_BITS];

wire underflow_or_subnormal;
assign underflow_or_subnormal =
    (norm_exp == EXT_EXP_ZERO) 
    || ((norm_exp == {EXP_ZERO, 1'b1}) 
    && (norm_mant[EXTRA_WIDTH-1] == 1'b0));

wire [EXP_WIDTH-1 : 0] out_exp;
assign out_exp = underflow_or_subnormal
    ? EXP_ZERO
    : norm_exp[EXP_WIDTH-1 : 0];

wire [MANT_WIDTH-1 : 0] out_mant;
assign out_mant = underflow_or_subnormal
    ? MANT_ZERO
    : rounded_mant[MANT_WIDTH-1 : 0];

wire out_sign;
assign out_sign = (addsub_zero || underflow_or_subnormal) ? 1'b0 : big_sign;

assign o_res = {out_sign, out_exp, out_mant};

endmodule