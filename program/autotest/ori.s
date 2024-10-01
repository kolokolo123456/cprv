# TAG = ori
.text

addi x29, x0, 5
ori x31, x29, 1
addi x28, x0, 10
ori x31, x28, 15
addi x27, x0, 20
ori x31, x27, 7
addi x26, x0, 25
ori x31, x26, 30
addi x25, x0, 35
ori x31, x25, 40

# max_cycle 50
# pout_start
# 00000005
# 0000000F
# 00000017
# 0000001F
# 0000002B
# pout_end