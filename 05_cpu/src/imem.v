`include "rv32i.vh"

module imem #(
    parameter DATAW = `INST_MEMW,
    parameter ADDRW = `INST_MEM_ADDRW,
    parameter INIT_FILE = `INST_MEM_INIT_FILE
) (
    input wire [ADDRW-1 : 0]  i_addr,
    output wire [DATAW-1 : 0] o_data
);

localparam DEPTH = 1 << ADDRW; 

reg [DATAW-1 : 0] mem [DEPTH-1 : 0];

initial begin
    $readmemh(INIT_FILE, mem);
end

assign o_data = mem[i_addr];

endmodule
