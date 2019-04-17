#####################  COD Lab ##############################
######## Using MARS for assembling and executing! ###########
##################### Zhehao Li #############################
.data
array: .word 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
print: .asciiz "\nThe sorted array : "
space: .asciiz " "

.text
.globl main
main:
la $t1,array    
li $s1,10      

# Read input, save them into array
Read: 
li $v0,5   #syscall 5: read integer from console
syscall
sw $v0,0($t1)
addi $t1,$t1,4
addi $s1,$s1,-1
bne  $s1, $zero, Read

# Measure time 1
li $v0,30
syscall
addi $s3,$a0,0
addi $s5,$a1,0

# Sort, the result should be that the smallest number will be on the left side.
la $t1, array
li $s1,36  # s1 is used as a flag to count. 
li $s2,0  # s2 is used to streamline the process: when there is no swap in one turn, end. 
li $s4,0  # counter

Sort_turn:  # one turn of sorting 
# Compare two adjacent numbers a[s4], a[s4+1]
add  $t2, $t1, $s4 	 # 
lw	$t3, 0($t2)   # t3 store the first number	
lw  $t4, 4($t2)   # t4 store the second number
blt	$t4, $t3, Swap	# if t4<t3, swap t3 and t4
# s4 increment 
Increment:
addi  $s4, $s4, 4		
bne	  $s4, $s1, Sort_turn #if s4==s1, then this turn is over
beq	  $s2, $zero, End	#if s2==0, there is no swap in one turn, end. 
li  $s2,0 # if s2==1, reset s2
addi  $s1, $s1, -4		
beq	  $s1, $zero, End	
li $s4,0  # counter
j   Sort_turn	

Swap:
sw	$t4, 0($t2)		#
sw	$t3, 4($t2)		# 
li $s2,1
j	Increment

End:
# Measure time 2
li $v0,30
syscall
addi $s6,$a0,0
addi $s7,$a1,0

# print "\n The sorted array:"
li $v0,4    
la $a0,print
syscall
# print sorted numbers
li $s4,0
li $s1,40
Print:
li $v0,1
add  $t2, $t1, $s4 	 # 
lw	$a0, 0($t2)		# 
syscall
li $v0,4
la $a0,space  # print space between numbers
syscall
addi  $s4, $s4, 4
bne $s4, $s1, Print


li $v0,10   
syscall
.end







