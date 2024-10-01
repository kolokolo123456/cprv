# TAG = and
	.text

	addi x28, x0, 1
	and x31,x28,x28
	addi x29, x0, 123
    addi x30, x0, 321
	addi x28, x0, 2024
    and x31, x29, x30
	and x31, x29, x29
	and x31, x28, x28

	# max_cycle 50
	# pout_start
	# 00000001
    # 00000041
	# 0000007B
	# 000007E8
	# pout_end
