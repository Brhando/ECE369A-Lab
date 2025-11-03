# ECE369 Lab 4–5 Comprehensive Test
# Brandon Sisco. Gavin Hernandez, Griffith Wiele
# 33%, 33%, 33%
# Verifies core instructions with NOP spacing (no hazard unit)

    .text
    .globl main

main:
    ########################################
    # Init
    ########################################
    addi $t0, $zero, 0          # t0 = 0 (base address)
    nop; nop; nop; nop; nop

    addi $t1, $zero, 6          # t1 = 6
    nop; nop; nop; nop; nop

    addi $t2, $zero, 10         # t2 = 10
    nop; nop; nop; nop; nop

    ########################################
    # Stores / Loads (word)
    ########################################
    sw   $t1, 0($t0)            # MEM[0]  = 6
    nop; nop; nop; nop; nop

    sw   $t2, 4($t0)            # MEM[4]  = 10
    nop; nop; nop; nop; nop

    lw   $s0, 0($t0)            # s0 = 6
    nop; nop; nop; nop; nop

    lw   $s1, 4($t0)            # s1 = 10
    nop; nop; nop; nop; nop

    ########################################
    # R-type ALU: sub, sll, srl, add, and, or, xor, nor, slt
    ########################################
    sub  $t3, $s1, $s0          # t3 = 10 - 6 = 4
    nop; nop; nop; nop; nop

    sll  $t4, $t3, 3            # t4 = 4 << 3 = 32
    nop; nop; nop; nop; nop

    srl  $t5, $t4, 2            # t5 = 32 >> 2 = 8
    nop; nop; nop; nop; nop

    add  $t6, $t1, $t2          # t6 = 6 + 10 = 16
    nop; nop; nop; nop; nop

    and  $t7, $t1, $t2          # t7 = 6 & 10 = 2
    nop; nop; nop; nop; nop

    or   $t8, $t1, $t2          # t8 = 6 | 10 = 14
    nop; nop; nop; nop; nop

    xor  $t9, $t1, $t2          # t9 = 6 ^ 10 = 12
    nop; nop; nop; nop; nop

    nor  $s7, $t1, $t2          # s7 = ~(6 | 10) = ...1111_0001 (two’s comp)
    nop; nop; nop; nop; nop

    slt  $s2, $t1, $t2          # s2 = (6 < 10) = 1
    nop; nop; nop; nop; nop

    ########################################
    # I-type ALU immediates: addi, andi, ori, xori, slti
    ########################################
    addi $s3, $zero, 6          # s3 = 6
    nop; nop; nop; nop; nop

    andi $s4, $s3, 0xFF80       # zero-extend imm: s4 = 6 & 0x00FF80 = 0
    nop; nop; nop; nop; nop

    ori  $s5, $s3, 0x8001       # zero-extend imm: s5 = 6 | 0x8001 = 0x8007
    nop; nop; nop; nop; nop

    xori $s6, $s3, 0x00FF       # zero-extend imm: s6 = 6 ^ 255 = 249
    nop; nop; nop; nop; nop

    slti $s4, $t1, 8            # s4 = (6 < 8) = 1  (sign-extended imm)
    nop; nop; nop; nop; nop

    ########################################
    # Byte/Half stores & loads (sign-extend on LB/LH)
    # Use addresses 8..15 to avoid overwriting word tests
    ########################################
    # Put pattern 0xAABB_CCDD at MEM[8] to reuse prior expectations if desired
    addi $at, $zero, 0xAABB     # $at = 0x0000AABB
    nop; nop; nop; nop; nop
    sll  $at, $at, 16           # $at = 0xAABB0000
    nop; nop; nop; nop; nop
    ori  $at, $at, 0xCCDD       # $at = 0xAABBCCDD
    nop; nop; nop; nop; nop
    sw   $at, 8($t0)            # MEM[8] = 0xAABBCCDD
    nop; nop; nop; nop; nop

    # LB from MEM[8 + off]: DD, CC, BB, AA (sign-extend)
    lb   $s0, 0($t0)            # s0 = MEM[0] low byte (6) — quick sanity (still OK)
    nop; nop; nop; nop; nop
    lb   $s1, 8($t0)            # s1 = 0xFFFFFFDD (since DD has MSB=1)
    nop; nop; nop; nop; nop
    lb   $s2, 9($t0)            # s2 = 0xFFFFFFCC
    nop; nop; nop; nop; nop
    lb   $s3, 10($t0)           # s3 = 0xFFFFFFBB
    nop; nop; nop; nop; nop
    lb   $s4, 11($t0)           # s4 = 0xFFFFFFAA
    nop; nop; nop; nop; nop

    # LH at MEM[8] -> CCDD ; at MEM[10] -> AABB (sign-extend)
    lh   $s5, 8($t0)            # s5 = 0xFFFFCCDD
    nop; nop; nop; nop; nop
    lh   $s6, 10($t0)           # s6 = 0xFFFFAABB
    nop; nop; nop; nop; nop

    # SB/SH: patch bytes/halves then read whole word
    sb   $zero, 9($t0)          # set CC -> 00  => word becomes AABB00DD
    nop; nop; nop; nop; nop
    sh   $t1, 10($t0)           # store half (6) at +10 => upper half = 0006
    nop; nop; nop; nop; nop
    lw   $s7, 8($t0)            # s7 should reflect edits
    nop; nop; nop; nop; nop

    ########################################
    # Branches: beq, bne (already), bgtz, blez, bltz, bgez
    # Your ALU expects B=const overlay; ConFlag indicates take/not
    ########################################
    # Prepare registers: $a0=0, $a1=+5, $a2=-3
    addi $a0, $zero, 0          # 0
    nop; nop; nop; nop; nop
    addi $a1, $zero, 5          # +5
    nop; nop; nop; nop; nop
    addi $a2, $zero, -3         # -3
    nop; nop; nop; nop; nop

    # bgtz $a1 -> branch (5 > 0)
    bgtz $a1, br_ok1
    addi $v0, $zero, 111        # should NOT execute
    nop; nop; nop; nop
br_ok1:
    addi $v0, $zero, 1
    nop; nop; nop; nop; nop

    # blez $a0 -> branch (0 <= 0)
    blez $a0, br_ok2
    addi $v1, $zero, 222        # should NOT execute
    nop; nop; nop; nop
br_ok2:
    addi $v1, $zero, 2
    nop; nop; nop; nop; nop

    # bltz $a2 -> branch (-3 < 0)
    bltz $a2, br_ok3
    addi $s0, $zero, 333        # should NOT execute
    nop; nop; nop; nop
br_ok3:
    addi $s0, $zero, 3
    nop; nop; nop; nop; nop

    # bgez $a1 -> branch (5 >= 0)
    bgez $a1, br_ok4
    addi $s1, $zero, 444        # should NOT execute
    nop; nop; nop; nop
br_ok4:
    addi $s1, $zero, 4
    nop; nop; nop; nop; nop

    ########################################
    # Jumps: j, jal, jr
    ########################################
    # jal should: write $ra = PC+4 (your design) and jump
    jal after_jal
    nop; nop; nop; nop; nop

    # If jal fails to jump, you’d hit these (treat as canary)
    addi $k0, $zero, 777
    nop; nop; nop; nop; nop

after_jal:
    # Move $ra into $t0 via add (no 'move' pseudo): t0 = ra + 0
    add  $t0, $ra, $zero
    nop; nop; nop; nop; nop

    # jr $ra: return to ret_target
    j set_ret_target
    nop; nop; nop; nop; nop

ret_target:
    addi $t1, $zero, 1234       # proves we returned here via jr
    nop; nop; nop; nop; nop
    j end
    nop; nop; nop; nop; nop

set_ret_target:
    # Put return target label address in $ra via jal to 'ret_target'
    jal ret_target
    nop; nop; nop; nop; nop

    # (We land here if jal returns after executing ret_target’s body)
    # Fall through to end
    nop; nop; nop; nop; nop

    ########################################
    # (Optional) MUL test — ONLY if your ALU writes ALUResult = Lo on mul
    ########################################
    # mul $t2,$t1,$t3  # expect low 32 in t2; uncomment if implemented that way
    # nop; nop; nop; nop; nop

end:
    # stick here forever
    j end
    nop
