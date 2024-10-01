# TAG = csrrwi
.text

addi x30, x0, 1
csrrwi x31, mstatus, 1
csrrwi x31, mstatus, 1
addi x30, x0, 1
csrrwi x31, mcause, 1
csrrwi x31, mcause, 1

# max_cycle 50
# pout_start
# 00000000
# 00000001
# 00000000
# 00000000
# pout_end