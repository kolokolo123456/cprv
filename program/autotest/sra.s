# TAG = sra
.text

addi x30, x0, 3
addi x29, x0, 128
sra x31, x29, x30
addi x28, x0, -64
sra x31, x28, x30
addi x27, x0, 1000
sra x31, x27, x30
addi x26, x0, -1000
sra x31, x26, x30
addi x25, x0, -1
sra x31, x25, x30

# max_cycle 50
# pout_start
# 00000010
# FFFFFFF8
# 0000007D
# FFFFFF83
# FFFFFFFF
# pout_end
