.text
.globl _start
.globl _finish

_start:
    nop

    # t6 = MMIO/output address 0x20
    li      t6, 0x20

    # ------------------------------------------------------------
    # 1. BEQ test: should branch because 5 == 5
    # ------------------------------------------------------------
    li      t0, 5
    li      t1, 5
    beq     t0, t1, test_beq_pass
    j       fail

test_beq_pass:
    li      t2, 1
    sw      t2, 0(t6)

    # ------------------------------------------------------------
    # 2. BNE test: should branch because 5 != 7
    # ------------------------------------------------------------
    li      t0, 5
    li      t1, 7
    bne     t0, t1, test_bne_pass
    j       fail

test_bne_pass:
    li      t2, 2
    sw      t2, 0(t6)

    # ------------------------------------------------------------
    # 3. BLT test: signed, should branch because -1 < 1
    # ------------------------------------------------------------
    li      t0, -1
    li      t1, 1
    blt     t0, t1, test_blt_pass
    j       fail

test_blt_pass:
    li      t2, 3
    sw      t2, 0(t6)

    # ------------------------------------------------------------
    # 4. BGE test: signed, should branch because 7 >= 7
    # ------------------------------------------------------------
    li      t0, 7
    li      t1, 7
    bge     t0, t1, test_bge_pass
    j       fail

test_bge_pass:
    li      t2, 4
    sw      t2, 0(t6)

    # ------------------------------------------------------------
    # 5. BLTU test: unsigned, should branch because 1 < 2
    # ------------------------------------------------------------
    li      t0, 1
    li      t1, 2
    bltu    t0, t1, test_bltu_pass
    j       fail

test_bltu_pass:
    li      t2, 5
    sw      t2, 0(t6)

    # ------------------------------------------------------------
    # 6. BGEU test: unsigned, should branch because 0xffffffff >= 1
    # ------------------------------------------------------------
    li      t0, -1
    li      t1, 1
    bgeu    t0, t1, test_bgeu_pass
    j       fail

test_bgeu_pass:
    li      t2, 6
    sw      t2, 0(t6)

    # ------------------------------------------------------------
    # 7. JAL test
    # ------------------------------------------------------------
    jal     test_jal_pass
    j       fail

test_jal_pass:
    li      t2, 7
    sw      t2, 0(t6)

    # ------------------------------------------------------------
    # 8. JALR test through register
    # ------------------------------------------------------------
    la      t0, test_jalr_pass
    jalr    t0
    j       fail

test_jalr_pass:
    li      t2, 8
    sw      t2, 0(t6)

    j       _finish


# ------------------------------------------------------------
# Failure path
# Writes 0xff to 0x20 and then hangs.
# ------------------------------------------------------------
fail:
    li      t2, 0xff
    sw      t2, 0(t6)
    j       fail


_finish:
    j       _finish