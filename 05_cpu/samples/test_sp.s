    .section .text
    .globl _start
    .globl _finish

_start:
    nop

    lui   sp, 0x1
    addi  sp, sp, 64      # sp = 0x1040

    addi  t0, zero, 0x11
    addi  t1, zero, 0x22

    sw    t0, 0(sp)       # addr 0x1040
    sw    t1, -64(sp)     # addr 0x1000

    lw    t2, 0(sp)       # should read 0x11

    addi  t3, zero, 0x11
    bne   t2, t3, bug

ok:
    addi  a0, zero, 0x11
    sh    a0, 32(zero)
    j _finish

bug:
    addi  a0, zero, 0x55
    sh    a0, 32(zero)
    j _finish

_finish:
    beqz    zero,  _finish
