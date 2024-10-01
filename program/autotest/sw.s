# TAG = sw

.text

addi x31, x0, 10
addi x31, x0, 25
sw x31, 0(x31)
lw x31, 0(x31)
addi x31, x0, 35
sw x31, 0(x31)

# max_cycle 50
# pout_start
# 0000000A
# 00000019
# 00000000
# 00000023
# 0000000A
# 00000019
# 00000000
# pout_end
