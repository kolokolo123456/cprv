# TAG = csrrci
.text

addi x30, x0, 2
csrrci x31, mstatus, 2
csrrci x31, mstatus, 2
addi x30, x0, 2
csrrci x31, mcause, 2
csrrci x31, mcause, 2

# max_cycle 50
# pout_start
# 00000000
# 00000000
# 00000000
# 00000000
# pout_end