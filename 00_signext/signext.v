module signext #(
    parameter N = 16,
    parameter M = 32,
    parameter BEHAVIORAL = 1
)(
    input  wire [N-1 : 0] i_val,
    output wire [M-1 : 0] o_ext
);

generate
if (BEHAVIORAL == 1) begin : gen__behavioral

    wire sign_bit;
    assign sign_bit = i_val[N-1];

    localparam EXT_WIDTH = M - N;

    assign o_ext = { {EXT_WIDTH{sign_bit}}, i_val};

end else begin : gen__struct
    genvar i;
    for (i = 0; i < N; i = i + 1) begin : gen__direct
        assign o_ext[i] = i_val[i];
    end

    for (i = N; i < M; i = i + 1) begin : gen__signbit
        signbit signbit_inst (
            .i_sign_bit(i_val[N-1]),
            .o_val(o_ext[i])
        );
    end
end
endgenerate

endmodule

module signbit (
    input  wire i_sign_bit,
    output wire o_val
);

assign o_val = i_sign_bit; 

endmodule


