# TAG = csrrc
.text

addi x30, x0, 2
csrrc x31, mstatus, x30
csrrc x31, mstatus, x30
addi x30, x0, 2
csrrc x31, mcause, x30
csrrc x31, mcause, x30

# max_cycle 50
# pout_start
# 00000000
# 00000000
# 00000000
# 00000000
# pout_end