HW_DIR := $(abspath $(CURDIR)/..)

TEST_SIZE ?= 4096
TEST_OP   ?= add
DEBUG     ?= 0
LAT ?= 3

TB_LIST := src/fp_tb.v
TOP = fp_tb

INC_LIST :=

FLAGS := -DADD_STAGE=add_$(LAT)st -DLATENCY=$(LAT) -DTEST_SIZE=$(TEST_SIZE) -DTEST_OP=$(TEST_OP) -DDEBUG=$(DEBUG) 

RTL_LIST := \
	src/fp_add.v \
	src/add_1st.v \
	src/add_2st.v \
	src/add_3st.v \

SYN_DEPS := gen_test
SIM_DEPS := gen_test

include ../common/fpga.mk

.PHONY: gen_test
 
gen_test:
	python3 test.py $(TEST_SIZE) $(TEST_OP) > test.txt