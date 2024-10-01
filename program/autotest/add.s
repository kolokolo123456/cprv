# TAG = add
.text

add x31, zero, zero
lui x28, 0x12345
add x31, x28, zero
add x31, x28, x31
add x31, x31, zero

# pout_start
# 00000000
# 12345000
# 2468A000
# 2468A000
# pout_end

# max_cycle 50
