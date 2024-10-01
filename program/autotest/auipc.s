# TAG = auipc
.text

addi x30, x0, 0
auipc x31, 1
auipc x31, 1000
auipc x31, 32768
auipc x31, 65535
auipc x31, 2024

# max_cycle 50
# pout_start
# 00002004
# 003E9008
# 0800100C
# 10000010
# 007E9014
# pout_end
