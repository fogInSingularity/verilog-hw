HW_DIR := $(abspath $(CURDIR)/..)

TB_LIST := src/uart_tb.v

RTL_LIST := \
	src/uart_tx.v \
	src/uart_tx_ctrl.v \
	src/uart_rx.v \
	src/uart_rx_ctrl.v \
	src/sync_1bit.v \
	src/negedge_detector.v \
	src/stall.v \
	$(HW_DIR)/02_clkdiv/clkdiv.v \

include ../common/fpga.mk