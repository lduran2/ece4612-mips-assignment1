# 2-factorial.asm
# This program accepts a user integer, and calculates and displays the
# facorial of that integer.
#
# created by:	Leomar Duran <https://github.com/lduran2>
#            	Yacouba Bamba
#            	Moussa Fofana 
#            	Tairou Ouro-Bawinay
#       date:	2020-09-28 t19:56Z
#        for:	ECE 4612
#            	MIPS_Assignment1

# service constants
.eqv	intprint   	1	# command to print integer $a0
.eqv	print   	4	# command to print $a0..NULL to the console
.eqv	intinput	5	# command to input an integer into $v0
.eqv	chrprint	11	# command to print character &a0

.text	# the code block
inpFct:
	# display the prompt
	la	$a0, factPrompt	# load the address of prompt buffer (null-terminated)
	la	$v0, print     	# print command
	syscall	# call print the prompt
inpFctInput:
	# get the integer from the console
	la	$v0, intinput  	# integer input command
	syscall	# call input an integer
inpFctFactorial:
	move	$a0, $v0       	# copy the input
	jal	factorial      	# call the factorial function on the input
inpFctFactorialStore:
	move	$s0, $v0       	# store the factorial
inpFctOutputLabel:
	la	$a0, ansPrompt 	# load the address of the answer label
	la	$v0, print     	# print command
	syscall	# call print the label
inpFctOutputNumber:
	move	$a0, $s0       	# copy the factorial
	li	$v0, intprint  	# print command
	syscall	# call print the factorial
inpFctOutputNewline:
	li	$a0, '\n'      	# load the newline character
	li	$v0, chrprint  	# print command
	syscall	# call print the newline
inpFctJmp:
	j	inpFct         	# repeat the program
# end inpFct

factorial:	# factorial n
	addi	$v0, $zero, 1         	# f := 1
factorialL1:
	beq	$a0, $zero, rFactorial	# branch out if ran out of numbers to multiply
	multu	$v0, $a0              	# f *= n
	mfhi	$v1                   	# v1:v0 = f
	mflo	$v0                   	#   "     "
	addi	$a0, $a0, -1          	# --n
	j	factorialL1           	# repeat
rFactorial:
	jr	$ra                   	# return to caller	
#

.data	# the data block
factPrompt:	.ascii "Enter a number to find factorial: \0\0"	# prompt for factorial
 ansPrompt:	.ascii "Ans: \0\0\0"	# label for answer
