sim: $(TB_LIST) $(RTL_LIST)
	iverilog -I./src/ $^ -o sim
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

syn:
	quartus_sh --flow compile system_top

gui:
	quartus system_top &

flash:
	quartus_pgm -c "USB-Blaster" -m JTAG -o "p;output_files/system_top.sof"

clean:
	rm -rf sim dump.vcd
	rm -rf db incremental_db output_files system_top.qws greybox_tmp *.bak
	$(MAKE) -C samples/ clean

.PHONY: syn flash clean gui sim waves