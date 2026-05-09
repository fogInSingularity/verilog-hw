localparam STATEW = 3;
localparam [STATEW-1 : 0] IDLE = 0, START = 1, SENDING = 2, RECEIVING = 3, STOP = 4;

localparam [0:0] HIGH = 1'b1, LOW = 1'b0;
