# input_copy.asm
# This program accepts a user string, up to 64 bytes, saves it to an array X, and copies from X to Y, as a null terminated string.
# created by:	Leomar Duran <https://github.com/lduran2>
#            	Yacouba Bamba
#            	Moussa Fofana 
#            	Tairou Ouro-Bawinay
#       date:	2020-09-26 t18:53
#        for:	ECE 4612
#            	MIPS_Assignment1

# the constants
.eqv	print	4	# command to print $a0..NULL to the console
.eqv	input	8	# command to input $a1 characters into $a0

.text	# the code block
inpCpy:
	# display the prompt
	la	$a0, cpyPrompt	# load the address of prompt buffer (null terminated)
	li	$v0, print    	# print command
	syscall	# call print
	# get the input from the console
	la	$a0, inpStr   	# load the address of input buffer
	la	$a1, inpStr   	# load the  length of input buffer
	li	$v0, input    	# input command
	syscall	# call input
#

.data	#  the data block
cpyPrompt:	.asciiz "Please enter a string.\n> "	# prompt for input
   inpStr:	.space 64	# the input buffer
   cpyStr:	.space 64	# the copy buffer
#
