.text
.globl _start
.globl _finish

_start:
    nop
    li x1, 1
    sw x1, 0x20(zero)
    li x1, 2
    sw x1, 0x20(zero)
    li x1, 3
    nop
    sw x1, 0x20(zero)
    li x1, 4
    sw x1, 0x20(zero)

_finish:
    beqz    zero,  _finish
