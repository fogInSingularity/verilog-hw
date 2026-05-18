HW_DIR := $(abspath $(CURDIR)/..)

TB_LIST := src/cpu_tb.v
TOP := cpu_tb

INC_LIST := \
	-I$(HW_DIR)/01_alu \
	-I$(HW_DIR)/01_cmp 

RTL_LIST := \
	$(HW_DIR)/00_signext/signext.v \
	$(HW_DIR)/01_alu/alu.v \
	$(HW_DIR)/01_cmp/cmp.v \
	$(HW_DIR)/02_rf_2r1w/regfile_2r1w.v \
	src/cpu.v \
	src/core.v \
	src/cdu.v \
	src/dmem.v \
	src/imem.v \
	src/lsu.v \
	src/regfile.v \
	src/mem_xbar.v \
	src/mmio_xbar.v

SYN_DEPS := samples
SIM_DEPS := samples

include ../common/fpga.mk

.PHONY: samples

samples:
	$(MAKE) -C samples
