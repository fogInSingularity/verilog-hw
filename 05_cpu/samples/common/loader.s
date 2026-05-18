.text
.globl _start
.globl _finish
.globl main

_start:
    nop
    li      sp, 0x1040
    call    main

_finish:
    beqz    zero,  _finish
