sim: $(TB_LIST) $(RTL_LIST) 
	iverilog -g2012 $^ $(INC_LIST) -o sim -DDEBUG=$(DEBUG)
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

clean:
	rm -rf sim dump.vcd

.PHONY: clean sim waves
