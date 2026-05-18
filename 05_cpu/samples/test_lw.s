    .section .text
    .globl _start

_start:
    nop

    # init stack
    lui   sp, 0x1
    addi  sp, sp, 64

    # memory[sp - 4] = 1
    addi  t1, zero, 1
    sw    t1, -4(sp)

    # poison t0 with 5
    addi  t0, zero, 5

    # load 1 into t0
    lw    t0, -4(sp)

    # should NOT branch:
    # correct: t0 = 1, so 1 >= 2 is false
    # buggy:   t0 = 5, so 5 >= 2 is true
    addi  t2, zero, 2
    bgeu  t0, t2, bug

ok:
    # display/store OK marker = 0x11
    addi  a0, zero, 0x11
    sh    a0, 32(zero)
    j _finish

bug:
    # display/store BUG marker = 0x55
    addi  a0, zero, 0x55
    sh    a0, 32(zero)
    j _finish

_finish:
    beqz    zero,  _finish
