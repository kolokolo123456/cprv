# TAG = srai
.text

addi x29, x0, 128
srai x31, x29, 3
addi x28, x0, -64
srai x31, x28, 3
addi x27, x0, 1000
srai x31, x27, 3
addi x26, x0, -1000
srai x31, x26, 3
addi x25, x0, -1
srai x31, x25, 3

# max_cycle 50
# pout_start
# 00000010
# FFFFFFF8
# 0000007D
# FFFFFF83
# FFFFFFFF
# pout_end
