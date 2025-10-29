# test_program.s
# Simple test program for pipelined datapath

.text
main:
    addi $t0, $zero, 5      # PC=0:  $t0 = 5
    nop
    nop
    nop
    nop
    nop
    
    addi $t1, $zero, 10     # PC=24: $t1 = 10
    nop
    nop
    nop
    nop
    nop
    
    add  $t2, $t0, $t1      # PC=48: $t2 = 15
    nop
    nop
    nop
    nop
    nop
    
    sub  $t3, $t1, $t0      # PC=72: $t3 = 5
    nop
    nop
    nop
    nop
    nop
    
    and  $t4, $t2, $t1      # PC=96: $t4 = 10
    nop
    nop
    nop
    nop
    nop
    
    or   $t5, $t2, $t1      # PC=120: $t5 = 15
    nop
    nop
    nop
    nop
    nop
    
    j main                   # PC=144: Loop back to start