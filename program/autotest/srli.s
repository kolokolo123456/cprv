# TAG = srli
.text

addi x29, x0, 128
srli x31, x29, 3
addi x28, x0, 96
srli x31, x28, 5
addi x27, x0, 1024
srli x31, x27, 2
addi x26, x0, -512
srli x31, x26, 4
addi x25, x0, -64
srli x31, x25, 1

# max_cycle 50
# pout_start
# 00000010
# 00000003
# 00000100
# 0FFFFFE0
# 7FFFFFE0
# pout_end
