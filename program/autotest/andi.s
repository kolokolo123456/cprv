# TAG = andi
.text

addi x29, x0, 15
andi x31, x29, 9
andi x31, x29, 12
andi x31, x29, 7
andi x31, x29, 3
andi x31, x31, 10

# max_cycle 50
# pout_start
# 00000009
# 0000000C
# 00000007
# 00000003
# 00000002
# pout_end