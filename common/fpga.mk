# icurus

sim: $(SIM_DEPS) $(TB_LIST) $(RTL_LIST)
	@iverilog -DICARUS_SIM -I./src/ $(INC_LIST) $^ -o sim
	@./sim

waves: dump.vcd
	@gtkwave dump.vcd > /dev/null 2>&1 &

lint: $(TB_LIST) $(RTL_LIST)
	@verilator --lint-only -DICARUS_SIM -Wall -I./src/ $(INC_LIST) $^

# modelsim

MSIM_INI_SRC ?= $(HOME)/intelFPGA/18.1/modelsim_ase/modelsim.ini

modelsim.ini:
	@cp $(MSIM_INI_SRC) modelsim.ini
	@chmod u+w modelsim.ini

MSIM_LIBS ?= -L altera_mf_ver
MSIM_WORK ?= work

MSIM_IP_LIST ?= $(wildcard ip/*.v)

# Convert Makefile-style -Ipath into ModelSim-style +incdir+path
MSIM_INC_LIST := +incdir+./src $(patsubst -I%,+incdir+%,$(INC_LIST))
MSIM_DEFINES := +define+QUARTUS_SYN

modelsim: modelsim.ini $(SIM_DEPS) $(TB_LIST) $(RTL_LIST) $(MSIM_IP_LIST)
	@rm -rf $(MSIM_WORK)
	@vlib $(MSIM_WORK)
	@vlog -work $(MSIM_WORK) $(MSIM_DEFINES) $(MSIM_INC_LIST) \
		$(MSIM_ALTERA_LIBS) \
		$(MSIM_IP_LIST) \
		$(RTL_LIST) \
		$(TB_LIST)
	@vsim -c $(MSIM_LIBS) $(MSIM_WORK).$(TOP) \
		-do "vcd file dump.vcd; vcd add -r /$(TOP)/*; run -all; quit -f"

# quartus

syn: $(SYN_DEPS)
	@quartus_sh --flow compile system_top

gui:
	@quartus system_top &

flash:
	@quartus_pgm -c "USB-Blaster" -m JTAG -o "p;output_files/system_top.sof"

# clean

clean:
	rm -rf sim dump.vcd
	rm -rf work transcript vsim.wlf modelsim.ini
	rm -rf db incremental_db output_files system_top.qws greybox_tmp *.bak
	$(MAKE) -C samples/ clean

.PHONY: syn flash clean gui sim waves lint modelsim