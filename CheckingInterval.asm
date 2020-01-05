# Made by Claudio
# September 19, 2019

.data
	error: .asciiz "Out of any interval"
	Interval1: .asciiz "Interval [0,25]"
	Interval2: .asciiz "Interval (25,50]"
	Interval3: .asciiz "Interval (50,75]"
	Interval4: .asciiz "Interval (75,100]"
	Zero: .float 0.0
	TwentyFive: .float 25.0
	Fifty: .float 50.0
	SeventyFive: .float 75.0
	Hundred: .float 100.0	
	
.text
	main:
		lwc1 $f2, Zero		# Sets the floating point registers to the desired values
		lwc1 $f4, TwentyFive
		lwc1 $f6, Fifty
		lwc1 $f8, SeventyFive
		lwc1 $f10, Hundred	
		
		li $v0, 6	# syscall code to read a floating point number
		syscall
		
		c.lt.s $f0, $f2	# compares the entered number to 0.00
		bc1f L1		# goes to next comparison if $f0 is bigger than 0.00
		j outOfInterval	# if the number isn't bigger than 0.00 then it's out of any interval
		
		L1:	
			c.le.s $f0, $f4	# checks if $f0 is less than 25.00
			bc1f L2
			j I1
		L2:
			c.le.s $f0, $f6	# checks if $f0 is less than 50.00
			bc1f L3
			j I2
		L3:
			c.le.s $f0, $f8	# checks if $f0 is less than 75.00
			bc1f L4
			j I3
		L4:
			c.le.s $f0, $f10	# checks if $f0 is less than 100.00
			bc1f outOfInterval
			j I4
		outOfInterval:
			li $v0, 4	# syscall code to print a string
			la $a0, error
			syscall
			j end	
		I1:
			li $v0, 4	# syscall code to print a string
			la $a0, Interval1
			syscall
			j end
		I2:
			li $v0, 4	# syscall code to print a string
			la $a0, Interval2
			syscall
			j end
		I3:
			li $v0, 4	# syscall code to print a string
			la $a0, Interval3
			syscall
			j end
		I4:
			li $v0, 4	# syscall code to print a string
			la $a0, Interval4
			syscall
			j end
		end:
	
