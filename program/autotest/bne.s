# TAG = bne
	.text
    
	addi x31, zero, 5
    bne zero, x31, fin
    addi x31, x31, 2

	fin:
	    addi x31, x31, 6

	# max_cycle 50
	# pout_start
    # 00000005
    # 0000000B
	# pout_end