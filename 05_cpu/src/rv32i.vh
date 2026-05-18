`ifndef RV32I_VH_
`define RV32I_VH_

`include "alu_ops.vh"
`include "cmp_ops.vh"
`include "cdu_conf.vh"
`include "lsu_conf.vh"

`define XLEN 32
`define BYTEW 8

`define REGW `XLEN
`define N_REGS 32
`define REG_ADDRW $clog2(`N_REGS)

`define INST_MEMW 32
`define INST_MEM_ADDRW 6

`ifdef ICARUS_SIM
`define INST_MEM_INIT_FILE "samples/meow.txt"
`elsif QUARTUS_SYN
`define INST_MEM_INIT_FILE "samples/meow.txt"
`endif

`define MMIO_LOW_ADDR `XLEN'h20
`define MMIO_HIGH_ADDR `XLEN'h24
`define DMEM_LOW_ADDR `XLEN'h1000

`define DATA_MEMW `XLEN
`define DATA_MEM_ADDRW 6

`define PCW `REGW
`define PC_INIT_VAL `PCW'h10000
`define PC_INC_VAL 4

`endif // RV32I_VH_
