# Lab 6 Full Hazard / Forwarding / Instruction-Coverage Test
# Includes all Table 1 instructions (no NOPs)
# Brandon Sisco, Gavin Hernandez, Griffith Wiele
# 33%, 33%, 33%

	.text
	.globl main

########################################
# main
########################################
main:
########################################
# Section 0: Initialization
########################################
    addi $t0, $zero, 0          # base address = 0
    addi $t1, $zero, 6          # t1 = 6
    addi $t2, $zero, 10         # t2 = 10

########################################
# Section 1: R-type forwarding & ALU ops
# add, sub, and, or, xor, nor, slt, sll, srl, mul
########################################
    add  $t3, $t1, $t2          # t3 = 6 + 10 = 16 (add)
    sub  $t4, $t2, $t1          # t4 = 10 - 6 = 4  (sub, RAW after t2)

    and  $t5, $t3, $t4          # t5 = 16 & 4 = 0
    or   $t6, $t3, $t4          # t6 = 16 | 4 = 20
    xor  $t7, $t3, $t4          # t7 = 16 ^ 4 = 20
    nor  $s0, $t3, $t4          # s0 = ~(16 | 4) = ~20

    slt  $s1, $t1, $t2          # s1 = (6 < 10) = 1
    slt  $s2, $t2, $t1          # s2 = (10 < 6) = 0

    sll  $s3, $t1, 2            # s3 = 6 << 2 = 24
    srl  $s4, $t2, 1            # s4 = 10 >> 1 = 5

    # mul via SPECIAL2 (Controller supports this)
    mul  $s5, $t1, $t2          # s5 = 6 * 10 = 60

########################################
# Section 2: I-type arithmetic/logical
# addi, slti, andi, ori, xori
########################################
    addi $s6, $zero, -1         # s6 = 0xFFFF_FFFF
    andi $s7, $s6, 0x00FF       # s7 = 0x0000_00FF
    ori  $t8, $zero, 0x00F0     # t8 = 0x0000_00F0
    xori $t9, $t8,   0x000F     # t9 = 0x0000_000F ^ 0x00F0 = 0x00FF
    slti $a0, $t1,   10         # a0 = (6 < 10) = 1
    slti $a1, $t2,   10         # a1 = (10 < 10) = 0

########################################
# Section 3: Memory operations
# lw, lh, lb, sw, sh, sb
########################################
    # Store a word, half, byte pattern into memory
    sw   $t1, 0($t0)            # MEM[0]  = 0x0000_0006
    sh   $t2, 4($t0)            # MEM[4]  = low half = 0x000A
    sb   $t8, 8($t0)            # MEM[8]  = low byte of 0x00F0 = 0xF0

    # Load them back with different sizes/sign behavior
    lw   $a2, 0($t0)            # a2 = 6
    lh   $a3, 4($t0)            # a3 = sign-extended 0x000A = 10
    lb   $v0, 8($t0)            # v0 = sign-extended 0xF0 = -16 (0xFFFF_FFF0)

########################################
# Section 4: Load-use hazard + store forwarding
########################################
    lw   $v1, 0($t0)            # v1 = 6 (load)
    add  $v1, $v1, $t1          # v1 = 6 + 6 = 12 (needs load-use stall)
    sw   $v1, 12($t0)           # MEM[12] = 12 (forward v1 to store)

########################################
# Section 5: Basic beq/bne branches (taken / not taken)
########################################
    beq  $t1, $t1, beq_taken    # taken
    addi $a0, $zero, 0          # should be flushed if beq taken

beq_taken:
    addi $a0, $zero, 1          # a0 = 1

    bne  $t1, $t1, bne_taken    # NOT taken
    addi $a1, $zero, 2          # a1 = 2, must execute

bne_taken:
    # no write here; just a label

########################################
# Section 6: Extended branch types
# blez, bgtz, bltz, bgez
########################################
    # Prepare some signed values:
    addi $s0, $zero, -5         # s0 = -5
    addi $s1, $zero,  0         # s1 = 0
    addi $s2, $zero,  3         # s2 = 3

    # blez: branch if <= 0 (should be taken with s0)
    addi $t3, $zero, 0          # t3 = 0
    blez $s0, blez_taken        # -5 <= 0 → taken
    addi $t3, $zero, 1          # should be flushed

blez_taken:
    addi $t3, $t3, 2            # t3 = 2

    # bgtz: branch if > 0 (should be taken with s2)
    addi $t4, $zero, 0          # t4 = 0
    bgtz $s2, bgtz_taken        # 3 > 0 → taken
    addi $t4, $zero, 1          # should be flushed

bgtz_taken:
    addi $t4, $t4, 3            # t4 = 3

    # bltz: branch if < 0 (should be taken with s0)
    addi $t5, $zero, 0          # t5 = 0
    bltz $s0, bltz_taken        # -5 < 0 → taken
    addi $t5, $zero, 1          # should be flushed

bltz_taken:
    addi $t5, $t5, 4            # t5 = 4

    # bgez: branch if >= 0 (should be taken with s2)
    addi $t6, $zero, 0          # t6 = 0
    bgez $s2, bgez_taken        # 3 >= 0 → taken
    addi $t6, $zero, 1          # should be flushed

bgez_taken:
    addi $t6, $t6, 5            # t6 = 5

########################################
# Section 7: Loop with bne and data dependencies
########################################
    addi $s3, $zero, 3          # loop counter = 3
    addi $s4, $zero, 0          # accumulator = 0

loop_start:
    addi $s4, $s4, 1            # s4++
    add  $s5, $s3, $s4          # s5 = s3 + s4 (uses forwarding)
    bne  $s3, $zero, loop_body  # while (s3 != 0) → taken until final
    j    loop_done

loop_body:
    addi $s3, $s3, -1           # s3--
    j    loop_start

loop_done:
########################################
# Section 8: JAL / JR test
########################################
    addi $v1, $zero, 0          # v1 = 0 (will hold "func ran" flag)
    jal  func                   # save return addr in $ra, jump
    addi $v1, $v1, 9            # runs after func returns

end:
    j    end                    # infinite loop

########################################
# func: test JR with $ra
########################################
func:
    addi $v1, $v1, 1            # v1 = v1 + 1 (mark func called)
    jr   $ra                    # return to caller