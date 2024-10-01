# TAG = xori
.text

addi x29, x0, 17
xori x31, x29, 10
addi x28, x0, -100
xori x31, x28, 255
addi x27, x0, 512
xori x31, x27, 256
addi x26, x0, -512
xori x31, x26, -1
addi x25, x0, -1
xori x31, x25, 511

# max_cycle 50
# pout_start
# 0000001B
# FFFFFF63
# 00000300
# 000001FF
# FFFFFE00
# pout_end