# TAG = jal
	.text

	addi x31, x0, 5
	jal x31, hey
	addi x30, x0, 10
	hey:
	# max_cycle 50
	# pout_start
	# 00000005
	# 00001008
	# pout_end