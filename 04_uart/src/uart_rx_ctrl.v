module uart_rx_ctrl #(
    parameter DATAW = 8
) (
    input wire clk,
    input wire rate_clk,
    input wire rst_n,

    input wire i_rx_sync,
    input wire i_rx_edge,

    output wire [DATAW-1 : 0] o_data,
    output wire o_vld
);

`include "uart.vh"

reg [DATAW-1 : 0] data;

// so vld and correct data alailable at the same time
stall #(
    .DATAW(DATAW),
    .STALL(0)
) stall_data (
    .clk(rate_clk),
    .rst_n(rst_n),
    .i_data(data),
    .o_data(o_data)
);

reg vld;
assign o_vld = vld;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        vld <= 1'b0;
    end else begin
        if (!vld && rate_clk) vld <= (state == STOP);
        else vld <= 1'b0;

        if (rate_clk) data <= {i_rx_sync, data[DATAW-1 : 1]};
    end
end

// FSM {{{

reg [STATEW-1 : 0] state;
reg [STATEW-1 : 0] next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else if (rate_clk) begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;

    case (state)
        IDLE:      if (i_rx_edge) next_state = RECEIVING; // NOTE: skip start
        RECEIVING: if (recv_cnt == DATAW - 1) next_state = STOP;
        STOP:      next_state = IDLE;
    endcase
end

// FSM }}}

localparam CNTW = $clog2(DATAW) + 1;
reg [CNTW-1 : 0] recv_cnt;

always @(posedge rate_clk or negedge rst_n) begin
    if (!rst_n) begin
        recv_cnt <= {CNTW{1'b0}};
    end else begin
        case (state)
            RECEIVING: recv_cnt <= recv_cnt + 1;
            STOP:      recv_cnt <= {CNTW{1'b0}};
        endcase
    end
end

endmodule