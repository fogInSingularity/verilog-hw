RISCV_TOOLCHAIN ?= ~/bin/bin
RISCV_PREFIX ?= $(RISCV_TOOLCHAIN)/riscv64-unknown-elf-

AS=$(RISCV_PREFIX)as
LD=$(RISCV_PREFIX)ld
CC=$(RISCV_PREFIX)gcc
OBJCOPY=$(RISCV_PREFIX)objcopy
OBJDUMP=$(RISCV_PREFIX)objdump
READELF=$(RISCV_PREFIX)readelf
FUNCSIM=whisper

S_SRCS=$(wildcard *.s)
C_SRCS=$(wildcard *.c)
S_TXTS=$(S_SRCS:%.s=%.txt)
C_TXTS=$(C_SRCS:%.c=%.txt)
S_MIFS=$(S_SRCS:%.s=%.mif)
C_MIFS=$(C_SRCS:%.c=%.mif)

all: $(S_TXTS) $(C_TXTS) $(S_MIFS) $(C_MIFS)

%.mif: %.txt
	python3 txt2mif.py $^ $@

%.txt: %.bin
	@hexdump -v -e '"%08x\n"' $^ > $@
	@python3 nop_pad.py $@

%.bin: %.out
	@$(OBJCOPY) -j .text -O binary $^ $@

%.out: %.s
	@$(AS) -march=rv32i -mabi=ilp32 -c $^ -o $^.o
	@$(LD) -melf32lriscv -Map=$@.map -T common/riscv.ld $^.o -o $@
	@$(OBJDUMP) -d --visualize-jumps -M no-aliases $@ > $@.dump

loader.o: common/loader.s
	@$(AS) -march=rv32i -mabi=ilp32 -c common/loader.s -o loader.o

%.out: %.c loader.o
	@$(CC) -nostdlib -march=rv32i -mabi=ilp32 -fPIC -s -O2 -c $< -o $<.o
	@$(LD) -melf32lriscv -Map=$@.map -T common/riscv.ld loader.o $<.o -o $@
	@$(OBJDUMP) -d --visualize-jumps -M no-aliases $@ > $@.dump

%.out.log: %.out .FORCE
	@$(FUNCSIM) -e 0x`$(READELF) -s $< | grep _finish | awk '{ print $$2 }'` -l $< | tee $@

.FORCE:

.PHONY: all clean

.PRECIOUS: %.o %.out %.bin %.txt

clean:
	@rm -f *.o *.out *.bin *.txt *.mif *.map *.log *.dump *.ver
