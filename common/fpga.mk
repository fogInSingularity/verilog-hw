sim: $(TB_LIST) $(RTL_LIST)
	iverilog -DICARUS_SIM -I./src/ $(INC_LIST) $^ -o sim
	./sim

waves: dump.vcd
	gtkwave dump.vcd > /dev/null 2>&1

lint: $(TB_LIST) $(RTL_LIST)
	verilator --lint-only -Wall -I./src/ $(INC_LIST) $^

syn: $(SYN_DEPS)
	quartus_sh --flow compile system_top

gui:
	quartus system_top &

flash:
	quartus_pgm -c "USB-Blaster" -m JTAG -o "p;output_files/system_top.sof"

clean:
	rm -rf sim dump.vcd
	rm -rf db incremental_db output_files system_top.qws greybox_tmp *.bak
	$(MAKE) -C samples/ clean



.PHONY: syn flash clean gui sim waves lint