# 3-check-matlab.asm
# This program validates a Matlab expression.
#
# created by:	Leomar Duran <https://github.com/lduran2>
#            	Yacouba Bamba
#            	Moussa Fofana 
#            	Tairou Ouro-Bawinay
#       date:	2020-09-30 t03:34Z
#        for:	ECE 4612
#            	MIPS_Assignment1
#    version:	1.3
######################################################################
#
# ChangeLog
######################################################################
#	(v1.5) - 2020-10-24 t13:07Z
#		Implemented the error from digraph using flags.
#
# 	(v1.4) - 2020-09-30 t07:44Z
# 		Implemented the error from digraph ends using linking.
#
# 	v1.3 - 2020-09-30 t03:34Z
# 		Implemented the "no operators since" flags.
#
# 	v1.2 - 2020-09-30 t02:37Z
# 		Implemented even parentheses cheaker.
#
# 	v1.0 - 2020-09-29 t23:21Z
# 		Implemented character validator.
#
#	Versions in parentheses are defunct.
######################################################################

# command constants
.eqv	intprint   	1	# command to print integer $a0
.eqv	print   	4	# command to print $a0..NULL to the console
.eqv	strinput	8	# command to input $a1 characters into buffer $a0
.eqv	chrprint	11	# command to print character &a0
# number constants
.eqv	lastchar	63	# index of last character in strinput
# flag masks
.eqv	flParError	64	# flags uneven parentheses
.eqv	flOpndOptr	1	# flags no operator since operand
.eqv	flClPrOptr	2	# flags no operator since closed parenthesis
.eqv	flDgSt    	1	# flags digraph start

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
	j	inpChkOutput             	# finish the loop
inpChkInvalid:
	la	$a0, invMessage          	# load address of invalid message
	addi	$v0, $zero, print        	# print command
	syscall	# print the message
	j inpChkOutput	# don't print the character index
inpChkIndex:	# used for debugging
	la	$a1, invMessage          	# load  length of invalid message
	add	$s0, $v1, $zero          	#  copy the error information
	andi	$a0, $s0, lastchar       	#  copy line number to print
	addi	$v0, $zero, intprint     	# print line number
	syscall	# print the line number
	j	inpChkOutput             	# finish the loop
inpChkOutput:
	addi	$a0, $zero, '\n'         	#  load newline
	addi	$v0, $zero, chrprint     	# print newline
	syscall	# print newline
	j	inpChk                   	# repeat the program
# end inpChk

# Validates a Matlab expression.
#
# The following rules are allowed:
#   expression is up to 64 characters
#   characters allowed [(-+\-/-9=A-Za-z]
#     only parentheses, digits from 0 to 9, and letters from a to z
#     (both upper and lower cases), operators +, -, *, /, and �=�.
#   no space between digits
#     no need because space is an invalid character
#   check for uneven parentheses
#   no operator between operand and open parenthesis
#   no operator between close parenthesis and operand
#   syntax errors:
#     (/
#     //
#     +/
#     -/
#     */
#     (*
#     /*
#     +*
#     -*
#     **
#     ()
#     /)
#     +)
#     -)
#     *)
#
# params:
#   $a0 := address of Matlab expressions
matchk: # matchk(char *X) : void
	# $t0 := index, k
	# $t1 := address, (X + k)
	# $t2 := character, X[k]
	# $t3 := boolean, if (X[k] < some character)
	# $t4 := character, temporary load
	# $t5 := counter, i_parentheses
	#                 of open parentheses - close parentheses
	# $t6 := flags for operator between
	# $t7 := flags for digraph start and end
	#
	# flow:
	# 	[(] -> dgst -> val
	# 	[)] -> dgfn -> val
	# 	[/*] -> dgfn -> dgst -> optr -> val
	# 	[+-] -> dgst -> optr -> val
	# 	[=] -> optr -> val
	# 	[0-9A-Za-z] -> opnd -> val
	#
	# (dgst, dgfn) are flags, checked in val, rather than
	# intermediate routines
	#
	and	$v1, $zero, $zero     	# clear $v1
	or	$t0, $zero, $zero       # for k = 0,
	or	$t5, $zero, $zero       # i_parentheses = 0
	and	$t6, $zero, $zero      	# clear operator between flags
	and	$t7, $zero, $zero      	# clear the digraph flags
matChkL1:
	add	$t1, $t0, $a1          	# find X + k
	lb	$t2, 0($t1)            	# get X[k] alias *(X + k)
	beq	$t2, $zero, matChkValid	# if (end of string), then valid
	addi	$t4, $zero, '\n'       	# load newline
	beq	$t2, $t4, matChkValid	# if (X[k] == newline), then valid
	j	matChkCharRng          	# check if the character is in range
matChkChVal:	# character is valid
	addi	$t0, $t0, 1            	# ++k
	j	matChkL1               	# next k
matChkInval:	# string is not valid
	and	$v0, $zero, $zero      	# clear valid flag
	or	$v1, $v1, $t0          	# $v1 |= k
	j	rMatChk                	# finish
matChkValid:
	bne	$t5, $zero, matChkInval	# invalid if parentheses uneven
	addi	$v0, $zero, 1          	#   set valid flag
rMatChk:
	jr	$ra                    	# return to caller
# end matchk

######################################################################
# Matlab check: character ranges
#   characters allowed [(-+\-/-9=A-Za-z]
#    , after +, : after 9, [ after Z, { after z
matChkCharRng:
matChkCharR10:	# character range 10 [(-+]
	ori	$t4, $zero, '('        	# load '('
	beq	$t2, $t4, matChkOpPar  	# if (X[k] == '(')  open parenthesis;
	ori	$t4, $zero, ')'        	# load ')'
	beq	$t2, $t4, matChkClPar  	# if (X[k] == ')') close parenthesis;
	ori	$t4, $zero, '*'        	# load '*'
	beq	$t2, $t4, matChkSlAs   	# if (X[k] == '*') slash or asterisk;
	ori	$t4, $zero, '+'        	# load '+'
	beq	$t2, $t4, matChkPlMn   	# if (X[k] == '+') plus or minus;
matChkCharMns:	# character -
	ori	$t4, $zero, '-'        	# load '-'
	beq	$t2, $t4, matChkPlMn   	# if (X[k] == '-') plus or minus;
matChkCharR20:	# character round 20 [/-9]
	ori	$t4, $zero, '/'        	# load '/'
	beq	$t2, $t4, matChkSlAs   	# if (X[k] == '/') slash or asterisk;
	sltiu	$t3, $t2, '0'          	# if (X[k] < '0')
	bne	$t3, $zero, matChkInval	#   invalid string;
	sltiu	$t3, $t2, ':'	       	# if (X[k] <= '9')
	bne	$t3, $zero, matChkOpnd 	#   operand;
matChkCharEqu:	# character =
	ori	$t4, $zero, '='        	# load '='
	beq	$t2, $t4, matChkEqls   	# if (X[k] == '=') equals;
matChkCharR30:	# character round 30 [A-Z]
	sltiu	$t3, $t2, 'A'          	# if (X[k] < 'A')
	bne	$t3, $zero, matChkInval	#   invalid string;
	sltiu	$t3, $t2, '['	       	# if (X[k] <= 'Z')
	bne	$t3, $zero, matChkOpnd 	#   operand;
matChkCharR40:	# character round 40 [a-z]
	sltiu	$t3, $t2, 'a'          	# if (X[k] < 'a')
	bne	$t3, $zero, matChkInval	#   invalid string;
	sltiu	$t3, $t2, '{'	       	# if (X[k] <= 'z')
	bne	$t3, $zero, matChkOpnd 	#   operand;
	j	matChkInval            	# else invalid string;
#

######################################################################
# # Matlab check: parentheses
matChkOpPar:	# character is an open parenthesis
	andi	$t3, $t6, flOpndOptr   	# if (no operator since last operand)
	bne	$t3, $zero, matChkInval	#   invalid string;
	addi	$t5, $t5, 1            	# ++i_parentheses
	ori	$t7, $t7, flDgSt	# start digraph
	j	matChkChVal            	#  open parenthesis is valid
matChkClPar:	# character is a close parenthesis
	andi	$t3, $t6, flClPrOptr   	# if (no operator since last close parenthesis)
	bne	$t3, $zero, matChkInval	#   invalid string;
	andi	$t3, $t7, flDgSt	# if (in digraph)
	bne	$t3, $zero, matChkInval	#   invalid string;
	addi	$t5, $t5, -1           	# --i_parentheses
	ori	$t6, $t6, flClPrOptr   	# flag no operator since last closed parenthesis
	j	matChkChVal            	# close parenthesis is valid
#

######################################################################
# # Matlab check: character classes
matChkEqls:
	and	$t7, $zero, $zero   	# end diagraph
	# fall through into operator
matChkOptr:	# character is an operator
	add	$t6, $zero, $zero   	# clear both between flags
	j	matChkChVal	    	# operator is valid
matChkOpnd:	# character is an operand
	andi	$t3, $t6, flClPrOptr   	# if (no operator since last close parenthesis)
	bne	$t3, $zero, matChkInval	#   invalid string;
	ori	$t6, $t6, flOpndOptr   	# flag no operator since last operand
	and	$t7, $zero, $zero   	# end diagraph
	j	matChkChVal	    	# operand is valid
matChkSlAs:	# character is slash or asterisk
	andi	$t3, $t7, flDgSt	# if (in digraph already)
	bne	$t3, $zero, matChkInval	#   invalid string;
	# otherwise, fall through into plus, minus
matChkPlMn:	# character is plus or minus
	ori	$t7, $t7, flDgSt	# start digraph
	j	matChkOptr	    	# plus, minus are operators
#

.data	#  the data block
 matPrompt:	.ascii ">>>\0"	# prompt for input
    inpStr:	.space 64	# the input buffer
invMessage:	.ascii "Invalid input\0\0\0"	# output for invalid input
valMessage:	.ascii "Valid input\0"      	# the input buffer
# end .data
