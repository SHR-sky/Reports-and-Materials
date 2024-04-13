.data
	prompt : .asciiz "\n Please input a value for N = "
	result: .asciiz " \n 1+2+...+n = "
	bye : .asciiz "\n Error with the input."
.text
	main:
		li $v0,4
		la $a0,prompt
		syscall
		li $v0,5 #input a integer
		syscall
		
	while:
		add $t0,$t0,$v0
		addi $v0,$v0,-1
		bnez $v0,while
		
		li $v0,4
		la $a0,result
		syscall
		
		li $v0,1
		move $a0,$t0
		syscall
		
		li $v0 ,10
		syscall