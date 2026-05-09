module uart_tx_ctrl #(
    parameter DATAW = 8
) (
    input wire clk,
    input wire rate_clk,
    input wire rst_n,

    output reg o_tx,

    input wire [DATAW-1 : 0] i_data,
    input wire i_vld,

    output wire o_ready
);

`include "uart.vh"

reg [DATAW-1 : 0] data;

always @(posedge clk) begin
    if ((state == IDLE) && sync_vld) data <= i_data;
    else if (state == SENDING && rate_clk) data <= data >> 1;
end

reg sync_vld;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sync_vld <= 1'b0;
    end else if (i_vld) begin
        sync_vld <= 1'b1;
    end else if (rate_clk) begin
        sync_vld <= 1'b0;
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
        IDLE:    if (sync_vld) next_state = START;
        START:   next_state = SENDING;
        SENDING: if (send_cnt == DATAW) next_state = STOP;
        STOP:    next_state = (sync_vld) ? START : IDLE;
    endcase
end

// FSM }}}

localparam CNTW = $clog2(DATAW) + 1;
reg [CNTW-1 : 0] send_cnt;

always @(posedge rate_clk) begin
    case (state)
        START:   send_cnt <= {CNTW{1'b0}}; 
        SENDING: send_cnt <= send_cnt + 1;
    endcase
end

always @(*) begin
    case (state)
        IDLE:    o_tx = HIGH;
        START:   o_tx = LOW;
        SENDING: o_tx = data[0]; // lsb first
        STOP:    o_tx = HIGH;
    endcase 
end

assign o_ready = (state == IDLE) && !sync_vld;

endmodule