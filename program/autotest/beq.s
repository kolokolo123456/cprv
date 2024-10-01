# TAG = beq
	.text
	beq zero,zero,a1
	addi x31,x31,5
	a1:
		addi x31,x31,6
	beq zero,x31,a1
	addi x31,x31,1

	# max_cycle 50
	# pout_start
	# 00000006
	# 00000007
	# pout_end
