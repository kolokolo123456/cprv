# TAG = xor
.text

addi x29, x0, 17
addi x30, x0, 10
xor x31, x29, x30
addi x28, x0, -100
xor x31, x30, x28
addi x27, x0, 255
xor x31, x29, x27
addi x26, x0, -207
xor x31, x26, x27
addi x25, x0, -1
xor x31, x25, x26

# max_cycle 50
# pout_start
# 0000001B
# FFFFFF96
# 000000EE
# FFFFFFCE
# 000000CE
# pout_end
