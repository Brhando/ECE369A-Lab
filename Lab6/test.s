############################################################
# Lab 6 Comprehensive Hazard / Forwarding Test
# - No NOPs
# - Stresses:
#     * EX/MEM & MEM/WB forwarding
#     * lw-use stall (load → ALU)
#     * lw → branch hazard
#     * ALU → store data forwarding
#     * beq / bne / j / jal / jr
#
# Expected behavior (high level):
#   - Uses memory at base address 0, 4, 8, ...
#   - Creates lots of data dependencies with no NOPs
#   - Ends in an infinite loop at label "end"
# Brandon Sisco, Gavin Hernandez, Griffith Wiele
# 33%, 33%, 33%
############################################################

        .data
array:  .word 6, 10, 0, 0, 0, 0, 0   # DataMemory[0]=6, [4]=10, [8]=0 initially

        .text
        .globl main

############################################################
# main
############################################################
main:
        ####################################################
        # Setup base and some simple constants
        # (matches the style of your Lab 4–5 sample)
        ####################################################
        addi $t0, $zero, 0        # t0 = 0, base address for DataMemory
        addi $t1, $zero, 6        # t1 = 6
        addi $t2, $zero, 10       # t2 = 10

        # Store initial values into memory to verify sw/lw
        sw   $t1, 0($t0)          # MEM[0] = 6
        sw   $t2, 4($t0)          # MEM[4] = 10

        ####################################################
        # Section 1: R-type arithmetic + EX/MEM forwarding
        ####################################################
        add  $t3, $t1, $t2        # t3 = 6 + 10 = 16
        sub  $t4, $t3, $t1        # hazard: uses t3 (EX/MEM forwarding) → 16 - 6 = 10
        and  $t5, $t3, $t2        # hazard: t3 forwarded again
        or   $t6, $t3, $t1        # or(16,6)
        slt  $t7, $t1, $t2        # t7 = (6 < 10) ? 1 : 0  → 1
        sll  $s0, $t7, 2          # s0 = 1 << 2 = 4
        srl  $s1, $s0, 1          # s1 = 4 >> 1 = 2

        ####################################################
        # Section 2: I-type arithmetic + sign extension
        ####################################################
        addi $s1, $zero, 0        # s1 = 0 (clean start for later loop)
        addi $s2, $zero, -1       # s2 = 0xFFFF_FFFF (tests sign-extension)
        ori  $s3, $zero, 0x00FF   # s3 = 0x000000FF (zero-extend imm)
        slti $s4, $s2, 0          # s4 = (s2 < 0) ? 1 : 0  → should be 1

        ####################################################
        # Section 3: Memory + load-use hazard (lw → ALU)
        ####################################################
        lw   $s5, 0($t0)          # s5 = MEM[0] = 6
        add  $s6, $s5, $t1        # lw-use hazard: s6 = 6 + 6 = 12
                                  # MUST stall 1 cycle then forward

        lw   $s7, 4($t0)          # s7 = MEM[4] = 10
        sub  $t8, $s7, $s5        # t8 = 10 - 6 = 4 (data from prior lw's)

        ####################################################
        # Section 4: ALU → store data forwarding
        ####################################################
        add  $t9, $t1, $t1        # t9 = 6 + 6 = 12
        sw   $t9, 8($t0)          # hazard: store uses forwarded t9
                                  # MEM[8] should get 12

        ####################################################
        # Section 5: Branch tests (beq / bne)
        # - also touches ID-stage forwarding
        ####################################################

        # Branch 1: beq taken (no load before, just ALU results)
        # t9 = 12, s6 = 12 from earlier
        beq  $t9, $s6, branch1_taken   # taken
        addi $a0, $zero, 0             # SHOULD BE SKIPPED if beq works

branch1_taken:
        addi $a0, $zero, 1             # mark: branch1 taken (a0 = 1)

        # Branch 2: bne not taken
        bne  $s5, $s5, branch2_taken   # NOT taken, since s5 == s5
        addi $a1, $zero, 2             # mark: fell through bne (bne not taken)

branch2_taken:
        # If something is wrong, this label might get hit (shouldn’t in correct run)

        ####################################################
        # Section 6: lw → branch hazard (load-use + branch)
        ####################################################
        lw   $t2, 0($t0)               # t2 = MEM[0] = 6
        beq  $t2, $s5, branch3_taken   # dependent on just-loaded t2
                                       # MUST stall + then branch taken

        addi $a2, $zero, 0             # SHOULD BE SKIPPED if branch works

branch3_taken:
        addi $a2, $zero, 3             # mark: branch3 taken (a2 = 3)

        ####################################################
        # Section 7: Small counted loop using bne
        # - exercises repeated branching and forwarding
        ####################################################
        addi $s0, $zero, 3             # loop counter = 3
        addi $s1, $zero, 0             # loop accumulator = 0

loop_start:
        addi $s1, $s1, 1               # s1++
        add  $s2, $s1, $s0             # hazard inside loop (forwarding)
        bne  $s0, $zero, loop_body     # while (s0 != 0) goto loop_body
        j    loop_done                 # if s0 == 0, exit

loop_body:
        addi $s0, $s0, -1              # s0--
        j    loop_start                # back to top

loop_done:
        ####################################################
        # Section 8: JAL / JR test (simple subroutine)
        ####################################################
        addi $v0, $zero, 0             # v0 = 0 (will be incremented in func)
        jal  func                      # PC+4 should go into $ra

        addi $v1, $zero, 9             # runs AFTER returning from func
                                       # (v1 = 9 just as a marker)

        ####################################################
        # Done: infinite loop
        ####################################################
end:
        j    end                       # stay here forever

############################################################
# func: simple function called via JAL
# - Increments v0 and returns with JR $ra
############################################################
func:
        addi $v0, $v0, 1               # v0 = v0 + 1 (should end up = 1)
        jr   $ra
