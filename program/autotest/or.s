# TAG = or
.text

addi x29, x0, 5
addi x30, x0, 3
or x31, x29, x30
addi x28, x0, 9
or x31, x28, x30
addi x27, x0, 12
or x31, x31, x27
addi x26, x0, 15
or x31, x26, x27
addi x25, x0, 17
or x31, x25, x28

# max_cycle 50
# pout_start
# 00000007
# 0000000B
# 0000000F
# 0000000F
# 00000019
# pout_end