# TAG = sub
.text

lui x30, 10
sub x31, x30, x0
addi x29, x0, 5
sub x31, x30, x29
sub x31, x29, x30
sub x31, x30, x31
sub x31, x31, x29
sub x31, x29, x31

# max_cycle 50
# pout_start
# 0000A000
# 00009FFB
# FFFF6005
# 00013FFB
# 00013FF6
# FFFEC00F
# pout_end
