# Made by Claudio and Beatriz
# October 31, 2019.

.data
	Initial_msg: .asciiz "\nLet's play a guessing game. \nFind out the number between 1 and 10 that I generated. \nEnter 0 to give up\n\n"
	Bigger_msg: .asciiz "\nMy number is bigger than that one...\n"
	Smaller_msg: .asciiz "\nMy number is smaller than that one...\n"
	Right_Answer_msg: .asciiz "\nYou've got it!"
	Game_Over_msg: .asciiz "\nNo more tries, I've won!\n"
	2tries_msg: .asciiz "You got two more tries.\n\n"
	1try_msg: .asciiz "You got one more try.\n\n"
	Number_msg: .asciiz "The number I chose was: "

	# $s0 -> Random number generated by the computer
	# $s1 -> Number chosen by the player
	# $s2 -> Number of tries

.text
main:
	li $v0, 42 # syscall code to generate a random number
	li $a1, 10 # sets the upper bound to 10
	syscall
	
	move $t0, $a0 # moves the genrated number to register $t0
	add $s0, $t0, 1 # add 1 to the number generated between 0-9
	add $s2, $zero, 3 # sets $s2 to the number of tries

	li $v0, 4 # syscall code to print a string
	la $a0, Initial_msg 
	syscall

	action:
		li $v0, 5 # syscall code to read an integer
		syscall
		move $s1, $v0 # saves in $s1

		beq $s1, $zero, end # verifies if the player has given up
		beq $s0, $s1, got_it # checks if the player has gotten right the number

		sub $s2, $s2, 1 # decreases the number of tries remaining
		beq $s2, $zero game_over # the number of tries have reached zero

		slt $t0, $s1, $s0
		beq $t0, 1, its_bigger

	its_smaller:
		li $v0, 4 # syscall code to print a string
		la $a0, Smaller_msg 
		syscall
		j more_actions

	its_bigger:
		li $v0, 4 # syscall code to print a string
		la $a0, Bigger_msg
		syscall

	more_actions:
		beq $s2, 2, 2_tries # restam 2 tentativas
		beq $s2, 1, 1_try # resta 1 tentativa

		j action

	2_tries:
		li $v0, 4 # syscall code to print a string
		la $a0, 2tries_msg 
		syscall
		j action

	1_try:
		li $v0, 4 # syscall code to print a string
		la $a0, 1try_msg 
		syscall
		j action

	got_it:
		li $v0, 4 # syscall code to print a string
		la $a0, Right_Answer_msg 
		syscall
		j end

	game_over:
		li $v0, 4 # syscall code to print a string
		la $a0, Game_Over_msg 
		syscall

		li $v0, 4 # syscall code to print a string
		la $a0, Number_msg 
		syscall

		li $v0, 1 # syscall code to print a integer
		la $a0, ($s0) # prints the number chosen by the computer

end:
	li $v0, 10 # Ends the game
	syscall