# TAG = slli
.text

addi x29, x0, 1
slli x31, x29, 3
slli x31, x29, 5
slli x31, x29, 10
slli x31, x29, 15
slli x31, x29, 20

# max_cycle 50
# pout_start
# 00000008
# 00000020
# 00000400
# 00008000
# 00100000
# pout_end
