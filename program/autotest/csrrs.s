# TAG = csrrs
.text

addi x30, x0, 1
csrrs x31, mstatus, x30
csrrs x31, mstatus, x30
addi x30, x0, 1
csrrs x31, mcause, x30
csrrs x31, mcause, x30

# max_cycle 50
# pout_start
# 00000000
# 00000001
# 00000000
# 00000000
# pout_end
