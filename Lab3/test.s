# ECE369 Lab 4 - Shorter Test Program
# Tests core instructions with proper NOP spacing

.text
.globl main

main:
    # Initialize registers
    addi $t0, $zero, 0          # PC=0: t0=0
    nop
    nop
    nop
    nop
    nop
    
    addi $t1, $zero, 6          # PC=24: t1=6
    nop
    nop
    nop
    nop
    nop
    
    addi $t2, $zero, 10         # PC=48: t2=10
    nop
    nop
    nop
    nop
    nop
    
    # Store/Load Test
    sw $t1, 0($t0)              # PC=72: Store 6 at mem[0]
    nop
    nop
    nop
    nop
    nop
    
    sw $t2, 4($t0)              # PC=96: Store 10 at mem[4]
    nop
    nop
    nop
    nop
    nop
    
    lw $s0, 0($t0)              # PC=120: s0=6
    nop
    nop
    nop
    nop
    nop
    
    lw $s1, 4($t0)              # PC=144: s1=10
    nop
    nop
    nop
    nop
    nop
    
    # Arithmetic Tests
    sub $t3, $s1, $s0           # PC=168: t3=10-6=4
    nop
    nop
    nop
    nop
    nop
    
    sll $t4, $t3, 3             # PC=192: t4=4<<3=32
    nop
    nop
    nop
    nop
    nop
    
    srl $t5, $t4, 2             # PC=216: t5=32>>2=8
    nop
    nop
    nop
    nop
    nop
    
    add $t6, $t1, $t2           # PC=240: t6=6+10=16
    nop
    nop
    nop
    nop
    nop
    
    and $t7, $t1, $t2           # PC=264: t7=6&10=2
    nop
    nop
    nop
    nop
    nop
    
    or $t8, $t1, $t2            # PC=288: t8=6|10=14
    nop
    nop
    nop
    nop
    nop
    
    slt $s2, $t1, $t2           # PC=312: s2=(6<10)=1
    nop
    nop
    nop
    nop
    nop
    
    # Branch Test - BEQ (should branch)
    addi $s3, $zero, 6          # PC=336: s3=6
    nop
    nop
    nop
    nop
    nop
    
    beq $t1, $s3, skip1         # PC=360: Should branch (6==6)
    addi $s4, $zero, 99         # Should NOT execute
    nop
    nop
    nop
    nop
    
skip1:
    addi $s4, $zero, 42         # PC=384: s4=42
    nop
    nop
    nop
    nop
    nop
    
    # Branch Test - BNE (should branch)
    bne $t1, $t2, skip2         # PC=408: Should branch (6!=10)
    addi $s5, $zero, 88         # Should NOT execute
    nop
    nop
    nop
    nop
    
skip2:
    addi $s5, $zero, 55         # PC=432: s5=55
    nop
    nop
    nop
    nop
    nop
    
    # Jump to end
    j end                       # PC=456: Jump to end
    nop
    nop
    nop
    nop
    nop
    
end:
    # Infinite loop
    j end                       # PC=480: Stay here forever
    nop