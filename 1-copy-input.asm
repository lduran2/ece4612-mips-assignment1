# 1-copy-input.asm
# This program accepts a user string, up to 64 bytes, saves it to an
# array X, and copies from X to Y, as a null terminated string.
#
# created by:	Leomar Duran <https://github.com/lduran2>
#            	Yacouba Bamba
#            	Moussa Fofana 
#            	Tairou Ouro-Bawinay
#       date:	2020-09-27 t03:26Z
#        for:	ECE 4612
#            	MIPS_Assignment1

# the constants
.eqv	print   	4	# command to print $a0..NULL to the console
.eqv	strinput	8	# command to input $a1 characters into buffer $a0

.text	# the code block

# Accept a uster string and save it.
inpCpy:
	# display the prompt
	la	$a0, cpyPrompt	# load the address of prompt buffer (null terminated)
	li	$v0, print    	# print command
	syscall	# call print
inpCpyInput:
	# get the input from the console
	la	$a0, inpStr   	# load the address of input buffer
	la	$a1, inpStr   	# load the  length of input buffer
	li	$v0, strinput  	# string input command
	syscall	# call input
inpCpyCopy:
	# copy the string
	la	$a0, cpyStr   	# load the address of the  copy buffer
	la	$a1, inpStr   	# load the address of the input buffer
	jal	strcpy        	# call strcpy
inpCpyJmp:
	j	inpCpy        	# repeat the program
# end inpCpy

# Copies a null-terminated string X at $a1 into buffer Y at $a0.
# params:
#   $a0 := address of destination character array
#   $a1 := address of source character array
strcpy: # strcpy(char *Y, char *X) : void
	add	$t0, $zero, $zero  	# for k = 0,
strCpyL1:
	add	$t1, $t0, $a1      	# find X + k
	lb	$t2, 0($t1)        	# get X[k] alias *(X + k)
	# wait until null terminator is copied to branch
	add	$t3, $t0, $a0	   	# find Y + k
	sb	$t2, 0($t3)        	# *(Y + k) := X[k]
	# now branch
	beq	$t2, $zero, rStrCpy	# if (X[k] == '\0') break;
	addi	$t0, $t0, 1        	# ++k
	j	strCpyL1		# next k
rStrCpy:
	jr	$ra                	# return to caller
# end strcpy

.data	#  the data block
cpyPrompt:	.ascii "Please enter a string.\n> \0\0\0"	# prompt for input
   inpLbl:	.ascii "upnIts tgnir\0\0\0:"	# label for input string in memory
   inpStr:	.space 64	# the input buffer
   cpyLbl:	.ascii "ypoCrts :gni"       	# label for copy string in memory
   cpyStr:	.space 64	# the copy buffer
# end .data
