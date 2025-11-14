.data
test_array: .word 9, 8, 7, 6, 0, 0, 0
.text

.globl main

main:
#la  $a0, test_array # address of test_array for QtSpim
addi $a0, $zero, 0 # address of test_array for real test (0,0) (20040000)
nop
nop
nop
nop
nop
addi $t0, $zero, 10 # t0 (WD) = 10 (0xA)
nop
nop
nop
nop
nop
addi $t1, $zero, 6 # t1 (WD) = 6 (0x6)
nop
nop
nop
nop
nop
sub $t2, $t0, $t1   # t2 (WD) = 4 (0x4)
nop
nop
nop
nop
nop
mul $t3, $t2, $t1   # t3 (WD) = 24 (0x18)
nop
nop
nop
nop
nop
add $t4, $t1, $t3   # t4 (WD) = 30 (0x1E)
nop
nop
nop
nop
nop
addi $t5, $zero, 32767  # t5 (WD) = 32767, 0x7FFF
nop
nop
nop
nop
nop
addi $t5, $t5, 32767  # t5 (WD) = 65...., 0xFFFE  
nop
nop
nop
nop
nop
addi $t5, $t5, 9031  # t5 (WD) = , 0x12345
nop
nop
nop
nop
nop
sw $t5, 16($a0) # [9,8,7,6,0x12345, 0, 0] 
nop
nop
nop
nop
nop
sh $t5, 20($a0) # [9,8,7,6,0x12345, 0x2345, 0]  
nop
nop
nop
nop
nop
sb $t5, 24($a0) # [9,8,7,6,0x12345,0x2345, 0x45] 
nop
nop
nop
nop
nop
lb $t6, 24($a0) # WD = t6 =  0x45
nop
nop
nop
nop
nop
lh $t6, 20($a0) # WD = t6 =  0x2345
nop
nop
nop
nop
nop
lw $t6, 16($a0) # WD = t6 = 0x12345
nop
nop
nop
nop
nop
xori $t5, $t1, 1 # WD = t5 =  0x7
nop
nop
nop
nop
nop
xor $t5, $t5, $t3 # WD = t5 =  0x1F
nop
nop
nop
nop
nop
andi $t5, $t3, 32767 # WD = t5 =  0x18
nop
nop
nop
nop
nop
and $t5, $t4, $t1 # WD = t5 =  0x6
nop
nop
nop
nop
nop
ori $t5, $t0, 1 # WD = t5 =  0xB
nop
nop
nop
nop
nop
or $t5, $t0, $t1 # WD = t5 =  0xE
nop
nop
nop
nop
nop
nor $t5, $t0, $t1 #  WD = t5 = 0xfffffff1 
nop
nop
nop
nop
nop
slti $t5, $t3, 1000 # WD = t5 = 0x1 
nop
nop
nop
nop
nop
slt $t4, $t4, $t3 # WD = t5 =  0x0 
nop
nop
nop
nop
nop
sll $t5, $t5, 8 # WD = t5 = 0x100
nop
nop
nop
nop
nop
srl $t5, $t5, 2 # WD = t5 =  0x40 
nop
nop
nop
nop
nop
bgtz $t0, b1  # branches
nop
nop
nop
nop
nop
addi $t0, $zero, -1
nop
nop
nop
nop
nop
b1: addi $t0, $zero, 1  # WD = t0 = 0x1
nop
nop
nop
nop
nop
addi $t0, $zero, -1 # WD = t0 = 0xffffffff
nop
nop
nop
nop
nop
bgez $t0, b2 # does not branch
nop
nop
nop
nop
nop
addi $t0, $zero, 5 #  WD = t0 = 0x5
nop
nop
nop
nop
nop
b2: addi $t0, $t0, 7 # WD = t0 = 0xC
nop
nop
nop
nop
nop
beq $t0, $t0, b3 # branches
nop
nop
nop
nop
nop
addi $t1, $zero, 10 #no exe 
nop
nop
nop
nop
nop
b3: addi $t1, $t1, 15  # WD = t1 = 0x15
nop
nop
nop
nop
nop
bne $t0, $t1, b4 # branches
nop
nop
nop
nop
nop
addi $t1, $zero, 20 #no exe 
nop
nop
nop
nop
nop
b4: addi $t1, $t1, 30 # WD = t1 = 0x33
nop
nop
nop
nop
nop
blez $t1, b5 # does not branch
nop
nop
nop
nop
nop
addi $t1, $zero, 40 # WD = t1 = 0x28
nop
nop
nop
nop
nop
b5: addi $t1, $t1, 50 # WD = t1 = 0x5A
nop
nop
nop
nop
nop
## part of jump and link, then exit (worth 20 pts)
addi $t5, $zero, 3 # # WD = t5 = 0x3
nop
nop
nop
nop
nop
b6: bltz, $t5, exit # 
nop
nop
nop
nop
nop
jal dummy_func # 
nop
nop
nop
nop
nop
j b6 # 
nop
nop
nop
nop
nop
dummy_func: addi $t5, $t5, -1 # decrement t5
nop
nop
nop
nop
nop
jr $ra # return to loop (03e00008)
nop
nop
nop
nop
nop
exit: j main
nop
nop
nop
nop
nop

