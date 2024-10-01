# TAG = sltiu
.text

addi x30, zero, 1000
sltiu x31, x30, 1001
addi x28, zero, -100
sltiu x31, x28, -99
addi x26, zero, 100
sltiu x31, x26, 100
addi x24, zero, -50
sltiu x31, x24, 0
addi x22, zero, -20
sltiu x31, x22, -50
addi x20, zero, 50
sltiu x31, x20, -100

# max_cycle 50
# pout_start
# 00000001
# 00000001
# 00000000
# 00000000
# 00000000
# 00000001
# pout_end
