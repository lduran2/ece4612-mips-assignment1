# 3-check-matlab.asm
# This program validates a Matlab expression.
#
# created by:	Leomar Duran <https://github.com/lduran2>
#            	Yacouba Bamba
#            	Moussa Fofana 
#            	Tairou Ouro-Bawinay
#       date:	2020-09-28 t22:17Z
#        for:	ECE 4612
#            	MIPS_Assignment1
#    version:	1.0
######################################################################
#
# ChangeLog
######################################################################
# 	v1.0 - 2020-09-29 t23:21Z
# 		Implemented character validator.
######################################################################

# the constants
.eqv	intprint   	1	# command to print integer $a0
.eqv	print   	4	# command to print $a0..NULL to the console
.eqv	strinput	8	# command to input $a1 characters into buffer $a0
.eqv	chrprint	11	# command to print character &a0

.text	# the code block

# Accept a uster string and save it.
inpChk:
	# display the prompt
	la	$a0, matPrompt           	# load the address of prompt buffer (null terminated)
	addi	$v0, $zero, print        	# print command
	syscall	# print the prompt
inpChkInput:
	# get the input from the console
	la	$a0, inpStr              	# load the address of input buffer
	la	$a1, inpStr              	# load the  length of input buffer
	addi	$v0, $zero, strinput     	# string input command
	syscall	# accept the matlab expression
inpChkValidate:
	# validate the string
	la	$a0, inpStr              	# load the address of the input buffer
	jal	matchk                   	# call matchk
	beq	$v0, $zero, inpChkInvalid	# if (valid string)
	la	$a0, valMessage          	# load address of valid message
	la	$a1, valMessage          	# load  length of valid message
	addi	$v0, $zero, print        	# print command
	syscall	# print the message
	j	inpChkOutput             	# print the message
inpChkInvalid:
	la	$a0, invMessage          	# load address of invalid message
	addi	$v0, $zero, print        	# print command
	syscall	# print the message
	la	$a1, invMessage          	# load  length of invalid message
	add	$a0, $zero, $v1          	#  copy line number to print
	addi	$v0, $zero, intprint     	# print line number
	syscall	# print the line number
	addi	$a0, $zero, '\n'         	#  load newline
	addi	$v0, $zero, chrprint     	# print newline
	syscall	# print newline
inpChkOutput:
	j	inpChk                   	# repeat the program
# end inpChk

# Validates a Matlab expression.
#
# The following rules are allowed:
#   expression is up to 64 characters
#   characters allowed [(-+\-/-9=A-Za-z]
#     only parentheses, digits from 0 to 9, and letters from a to z
#     (both upper and lower cases), operators +, -, *, /, and “=”.
#   no space between digits
#   check for uneven parentheses
#   no operator between operand and open parenthesis
#   no operator between close parenthesis and operand
#   syntax errors:
#     (/
#     (*
#     ()
#     /)
#     //
#     /*
#     +/
#     +*
#     +)
#     -/
#     -*
#     -)
#     **
#     */
#     *)
#     */
#     *)
#
# params:
#   $a0 := address of Matlab expressions
matchk: # matchk(char *X) : void
	add	$t0, $zero, $zero       # for k = 0,
matChkL1:
	add	$t1, $t0, $a1           # find X + k
	lb	$t2, 0($t1)             # get X[k] alias *(X + k)
	beq	$t2, $zero, matChkValid	# if (end of string), then valid
	addi	$t4, $zero, '\n'       	# load newline
	beq	$t2, $t4, matChkValid	# if (X[k] == newline), then valid
matChkChar:
	# characters allowed [(-+\-/-9=A-Za-z]
	# , after +, : after 9, [ after Z, { after z
matChkCharR1:	# character round 1 [(-+]
	sltiu	$t3, $t2, '('           # if (X[k] < '(')
	bne	$t3, $zero, matChkInval	#   invalid string;
	sltiu	$t3, $t2, ','	       	# if (X[k] <= '+')
	bne	$t3, $zero, matChkChVal	#   valid character;
matChkCharMns:	# character -
	addi	$t4, $zero, '-'        	# load '-'
	beq	$t2, $t4, matChkChVal  	# if (X[k] == '-') valid character;
matChkCharR2:	# character round 2 [/-9]
	sltiu	$t3, $t2, '/'          	# if (X[k] < '/')
	bne	$t3, $zero, matChkInval	#   invalid string;
	sltiu	$t3, $t2, ':'	       	# if (X[k] <= '9')
	bne	$t3, $zero, matChkChVal	#   valid character;
matChkCharEqu:	# character =
	addi	$t4, $zero, '='        	# load '='
	beq	$t2, $t4, matChkChVal  	# if (X[k] == '=') valid character;
matChkCharR3:	# character round 3 [A-Z]
	sltiu	$t3, $t2, 'A'          	# if (X[k] < 'A')
	bne	$t3, $zero, matChkInval	#   invalid string;
	sltiu	$t3, $t2, '['	       	# if (X[k] <= 'Z')
	bne	$t3, $zero, matChkChVal	#   valid character;
matChkCharR4:	# character round 4 [a-z]
	sltiu	$t3, $t2, 'a'          	# if (X[k] < 'a')
	bne	$t3, $zero, matChkInval	#   invalid string;
	sltiu	$t3, $t2, '{'	       	# if (X[k] <= 'z')
	bne	$t3, $zero, matChkChVal	#   valid character;
	j	matChkInval            	# else invalid string;
matChkChVal:	# character is valid
	addi	$t0, $t0, 1            	# ++k
	j	matChkL1               	# next k
matChkInval:
	add	$v0, $zero, $zero      	# clear valid flag
	add	$v1, $zero, $t0       	# copy k
	j	rMatChk                	# finish
matChkValid:
	addi	$v0, $zero, 1          	#   set valid flag
rMatChk:
	jr	$ra                    	# return to caller
# end matchk

.data	#  the data block
 matPrompt:	.ascii ">>>\0"	# prompt for input
    inpStr:	.space 64	# the input buffer
invMessage:	.ascii "Invalid input at: \0\0"	# output for invalid input

valMessage:	.ascii "Valid input\n\0\0\0\0"      	# the input buffer
# end .data
