# TAG = lw
	.text
     
    addi x31,x0,9
	lw x31,0(x31)
	addi x31,x31,2
	lw x31,0(x31)
	lw x31,4(x31)
	# max_cycle 50
	# pout_start
	# 00000009
	# 00000000
	# 00000002
	# 00000000
	# 00000000
	# pout_end
