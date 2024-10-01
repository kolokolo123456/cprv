# TAG = addi
.text

addi x31, zero, 0
addi x31, zero, 10
addi x31, zero, -5
addi x31, x31, 5 
addi x31, x31, 200

# pout_start
# 00000000
# 0000000A
# FFFFFFFB
# 00000000
# 000000C8
# pout_end

# max_cycle 50
