`include "rv32i.vh"

module imem #(
    parameter DATAW = `INST_MEMW,
    parameter ADDRW = `INST_MEM_ADDRW,
    parameter INIT_FILE = `INST_MEM_INIT_FILE
) (
    input wire clk,
    input wire rst_n,

    input wire [ADDRW-1 : 0] i_addr,
    output wire [DATAW-1 : 0] o_data
);

localparam DEPTH = 1 << ADDRW; 

`ifdef ICARUS_SIM

reg [DATAW-1 : 0] mem [DEPTH-1 : 0];

initial begin
    $readmemh(INIT_FILE, mem);
end

reg [ADDRW-1 : 0] addr_ff;

always @(posedge clk or negedge rst_n) begin
    addr_ff <= (!rst_n) ? `PC_INIT_VAL : i_addr;
end

assign o_data = mem[addr_ff];

`elsif QUARTUS_SYN

wire rst;
assign rst = ~rst_n;

imem_1r_256x32 #(
    .INIT_FILE(`INST_MEM_INIT_FILE)
) imem_1r_256x32_inst (
    .aclr           (rst    ),
    .address        (i_addr ),
    .clock          (clk    ),
    .q              (o_data )
);

`endif

endmodule
