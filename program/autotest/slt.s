# TAG = slt
.text

addi x30, zero, 5
slt x31, x30, zero
beq x30, zero, fin

addi x28, zero, -10
slt x31, zero, x28
addi x26, zero, 3
slt x31, x26, x30
slt x23, x24, x31
addi x24, zero, 7
addi x22, zero, 5
slt x31, x22, x30

fin:
    addi x31, zero, 7

# max_cycle 50
# pout_start
# 00000000
# 00000000
# 00000001
# 00000000
# 00000007
# pout_end