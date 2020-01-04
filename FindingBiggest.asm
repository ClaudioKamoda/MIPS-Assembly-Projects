# Made by Claudio, Beatriz and Israel
# September 19, 2019

# Finding the biggest of three numbers :)

.data
msg: .asciiz "\nInsert the first number:\n"
msg2: .asciiz "\nInsert the second number:\n"
msg3: .asciiz "\nInsert the third number:\n"
msg4: .asciiz " is the biggest\n"

.text

main:
	li $v0, 4	# syscall code to print a string
	la $a0, msg
	syscall
	
	li $v0, 5	# syscall code to get an int
	syscall
	
	move $s1, $v0	# move the entered int to register $s1

	li $v0, 4	# syscall code to print a string
	la $a0, msg2
	syscall
	
	li $v0, 5	# syscall code to get an int
	syscall
	
	move $s2, $v0	# move the entered int to register $s2

	li $v0, 4	# syscall code to print a string
	la $a0, msg3
	syscall
	
	li $v0, 5	# syscall code to get an int
	syscall
	
	move $s3, $v0	# move the entered int to register $s3

	bgt $s1, $s2, check	# check if $s1 is bigger than $s2, if so go to label 'check'
	bgt $s2, $s3, BIG_2	# if $s2 is bigger than $s1, check if $s2 is also bigger than $s3. If it is, then $s2 is the biggest
	j BIG_3 		# proceed to print $s3 as the biggest number

	check:
		bgt $s1, $s3, BIG_1	# check if $s1 is also bigger than $s3. If it is, then $s1 is the biggest.
		j BIG_3			# if $s3 is bigger than $s1, then $s3 is the biggest
		
	BIG_1:			# print $s1 as the biggest
		li $v0, 1	# syscall code to print an integer
		la $a0, ($s1)
		syscall
	
		li $v0, 4	# syscall code to print a string
		la $a0, msg4
		syscall
		j end

	BIG_2:			# print $s2 as the biggest
		li $v0, 1	# syscall code to print an integer
		la $a0, ($s2)
		syscall
		
		li $v0, 4	# syscall code to print a string
		la $a0, msg4
		syscall
		j end
	
	BIG_3:			# print $s3 as the biggest
		li $v0,1	# syscall code to print an integer
		la $a0, ($s3)
		syscall
		
		li $v0, 4	# syscall code to print a string
		la $a0, msg4
		syscall

end:
	li $v0, 10	# syscall code to finish the program
	syscall