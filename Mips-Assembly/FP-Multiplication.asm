.data
num1: .word 0xc47a2000 #-1000.5
num2: .word 0x42c90000 #100.5
result: .asciiz "Multiplication of -1000.5, 100.5 in hex is 0xc7c46320 = -100550.25\n"
note: .asciiz "NOTE: result is in register $a1\n"
.text
.globl main
main:
	la $t0, num1
	lw $t1, ($t0)
	
	beq $t1, $0, zero #if (num1 == 0)
	
	#s0 = sign1
	srl $s0, $t1, 31 #s0 = t1[31], 1 bit

	#s1 = exponent1
	srl $s1, $t1, 23 #s1 = t1[30:23], 8 bits
	andi $s1, $s1, 0x000000ff #masking 1 bit of sign
	
	#s2 = mantissa1
	add $s2, $t1, $0 #s2 = t1[22:0], 23 bits
	andi $s2, $t1, 0x007fffff #masking 9 bits of exp & sign
	ori $s2, $s2, 0x00800000  #add leading 1 to mantissa
	
	la $t0, num2
	lw $t2, ($t0)
	
	beq $t2, $0, zero #if (num2 == 0)
	
	#s3 = sign2
	srl $s3, $t2, 31 #s3 = t2[31], 1 bit

	#s4 = exponent2
	srl $s4, $t2, 23 #s4 = t2[30:23], 8 bits
	andi $s4, $s4, 0x000000ff #masking 1 bit of sign
	
	#s5 = mantissa2
	add $s5, $t2, $0 #s5 = t2[22:0], 23 bits
	andi $s5, $t2, 0x007fffff #masking 9 bits of exp & sign
	ori $s5, $s5, 0x00800000  #add leading 1 to mantissa
	
	j sign_calculation
main1:	
	j add_exponent
main2:
	j multiply_mantissa
main3:
	j normalize
main4:
	sll $t5, $t5, 31 #shift sign to its actual index
	sll $t6, $t6, 23 #shift exp to its actual index
	andi $t7, $t7, 0x007fffff #masking 9 bits of exp & sign
	or $a1, $t5, $t6 #concatenate sign & exp
	or $a1, $a1, $t7 #concatenate mantissa
			 #$a1 = final result
	j end		 
zero:
	li $a1, 0
end:
	la $a0, result
	li $v0, 4
	syscall
	
	la $a0, note
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
#-----------------------------------	
sign_calculation:	
	beq $s0, $s3, pos #if (++) or (--)
	li $t5, 1 #t5 = final sign negative
	j main1
pos:
	li $t5, 0 #t5 = final sign positive
	j main1
#-----------------------------------	
add_exponent:
	subi $t6, $s1, 127
	add $t6, $t6, $s4 #$t6 = final exponent
	j main2
#-----------------------------------	
multiply_mantissa:
	mult $s2, $s5 
	mfhi $t3 #$t3 = hi of multiplication
	mflo $t4 #$t4 = lo of multiplication
	j main3
#-----------------------------------
normalize:
	srl $s7, $t3, 15 #get msb (msb of multi is 48, in register is 16)
	bne $s7, $0, notZero #if (msb != 0)
	sll $t7, $t3, 7  #shift hi of multiplication
	srl $t4, $t4, 25 #shift lo of multiplication
	or $t7, $t7, $t4 #t7 = final mantissa
	j main4
notZero:
	sll $t7, $t3, 8  #shift hi of multiplication
	srl $t4, $t4, 24 #shift lo of multiplication
	or $t7, $t7, $t4 #t7 = final mantissa
	addi $t6, $t6, 1 #add 1 to exponent
	j main4
	
	
	
