# TAG = jalr
    .text

    addi x31, x0, 6
    jalr x31, x31, 0
    addi x30, x0, 10
    # max_cycle 50
    # pout_start
    # 00000006
    # 00001008
    # pout_end