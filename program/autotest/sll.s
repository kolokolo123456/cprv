# TAG = sll
.text

addi x30, x0, 3
addi x29, x0, 1
sll x31, x29, x30
sll x31, x29, 5
sll x31, x29, 10
sll x31, x29, 15
sll x31, x29, 20

# max_cycle 50
# pout_start
# 00000008
# 00000020
# 00000400
# 00008000
# 00100000
# pout_end
