.data
	printold: 		.asciiz "old.\n"
	printnew: 		.asciiz "new.\n"
    printnewline: 		.asciiz "\n"
 mainLoopCounter: 		.asciiz "\nMain Loop Counter:"
 Counter:	  		.asciiz "\nCount:"
 maxmainLoopCounter: 		.asciiz "\nMax Main Loop Counter:"
 yourfinalpopulatedarray: 	.asciiz "\nFinal Populated array:\n"
 comma: 			.asciiz  ","
 inStateA: 			.asciiz "\nIn State A\n"
 inStateB: 			.asciiz "\nIn State B\n" 
 iteration: 			.asciiz "\nIteration #:\n"
 
 newline: .asciiz "\n"
reference: .asciiz "\n\nreference:"
index: .asciiz "\nindex:"
tag: .asciiz "\ntag:"
validityBit: .asciiz "\nvalidity bit:"
tagincache: .asciiz "\nTag in cache:"
updatedtag: .asciiz "\nUpdated tag:"
updatedvaliditybit: .asciiz "\nUpdate validity bit:"
hitcountervalue: .asciiz "\n\nHit Counter:"
misspenaltycountervalue: .asciiz "\nMiss Penalty Counter:"
printhit: .asciiz "\nTag values match. Its a hit."
promptBlock: .asciiz "\nEnter the block size: "
promptCache: .asciiz "\nEnter the cache size: "
eat: .asciiz "\nEffective Memory Access Time: "
cmt: .asciiz "\nComputed Memory Access Time "
million: .float 1000000.0
printmiss: .asciiz "\nIt is a miss"

tag_array: .word -1:8192
validity_array: .word 0:8192 
 
.align 2
  circularbuffer: .space  48 
.align 2
      finalarray: .space  4000000
	
.text
	
	li	$t0, 1000000	#Counter max value
	li	$t1, 0		#Counter i
	li	$t3, 1		#New Initial flag
	li	$t4, 0		#old Initial flag
	li 	$s1, 0		#Counter for New
	li	$s2, 0 		#counter for Old
	
	
	li	$s5, 12		#size of the buffer
	li 	$t8, 0		#Circular buffer counter
		
	loop:
	bge 	$t1, $t0, main1
	
	
	
	
	#Loop body
	#Here jump to ComputeNextState(); // This function returns New or Old
	j ComputeNextState
	backtocomp:
	li 	$t6, 0
	beq 	$t5, $t6, ifnew
	bne  	$t5, $t6, ifold
	
	
	#ifnew:
	#li      $v0, 4
	#la      $a0, printnew
	#syscall
	#j followon
	#ifold:
	#li      $v0, 4
	#la      $a0, printold
	#syscall
	
	
	#la   	$s7, circularbuffer		#  load base address of array into register $s7
	
	ifnew:
	
	la   	$s7, circularbuffer		#  load base address of array into register $s7
	li     	$a1, 2147483647  #Here you set $a1 to the max bound. This will take maximum 17 bits to represent
	#generates the random number and stores it into $a0.
        li    	$v0, 42            
	syscall
	#make sure this is  perfectly divisible by 4
	li     $k0, 4
    	div    $a0, $k0        # divide the value of $a0 the random number by 4
    	mfhi   $k1              # store the remainder in $k1
    	#subtract the remainder from $a0
    	sub $t5, $a0, $k1
    	
	#Now we have to find the index where this number is gonna get stored
	divu	$t8, $s5
	mfhi    $s6      
	
	#here we multiply the contents of $s6 by 4
	li 	$t9, 4
	mult    $t9, $s6
	mflo    $k1
		
	#now we add this to the circular buffer start point
	li      $k0, 0                		#clean $k0 before use
	add  	$k0, $s7, $k1 
	
	#now we have to store the random address in $a0 (now in $t5) at the index $s6 in the circular buffer.
	sw 	$t5, ($k0)
	
	#after this we should increement the index at $t8, this is the circular buffer counter
	addi 	$t8, $t8, 1
	
	
	j addressGenerationLoop
	
	ifold:
	
	la   	$s7, circularbuffer		#  load base address of array into register $s7
	#pick up a random value A from buffer
	#use t7, k0
	#li     	$a1, 12  #Here you set $a1 to the max bound. 
	bgt 	$t8, 11, greaterthan11
	blt	$t8, 12, lessthan12
	greaterthan11:
	li     	$a1, 12  #Here you set $a1 to the max bound.
	j 	ifoldcontinue 
	lessthan12:
	move	$a1, $t8
	j	ifoldcontinue
	
	ifoldcontinue:
	#generates the random number and stores it into $a0.
        li    	$v0, 42            
	syscall
	move $t7, $a0
	#here we multiply the contents of $s6 by 4
	li 	$s6, 4
	mult    $t7, $s6
	mflo    $k0
	
	#now we want to pick the same from the cicular buffer , We can use t5
	add 	$a3, $s7, $k0
	lw 	$t5, ($a3)    #now $t5 will server as a random address generator for addressGenerationLoop
	
	
	j addressGenerationLoop
	
	addressGenerationLoop:
	#now we have to take M as 256
	li      $k0, 256
	#li		$a1, 512
	#li      $v0, 42            
	#syscall
	#move      $k0, $a0
	
	#iterate over $k0 => M and generate 256 addresses
	#for (i= A; i <=A+M;i++){
        #		Process Address i; // extract index, is it in cache?.....
        #		In our case, we will store it in a global array
	#}
	
	#load the address of the Final array 
	la	$s3,  finalarray
	#set the loop counter
	li      $t7,  0
	#temp variable
	li 	$t9,  0
	
	loopinsertfinalarray:
	beq	$t7,  $k0 , endloopinsertfinalarray   #run the loop for 256 times
	
	#this is done to select a place to update in final array
	li 	$k1,   4
	mult    $t1,   $k1
	mflo    $t9
	#cleab $k1 before use
	li 	$k1,   0
	add     $k1,   $s3, $t9
	sw	$t5,  ($k1)		#$t5 is the random address
	#addi	$s3,   $s3, 4		#increement the index of the array 
	addi	$t7,   $t7, 1		#increement the counter for 256	   	
	addi    $t5,   $t5, 4		#increement the A address to get the next address
	addi 	$t1,   $t1, 1  		#increement the total number of array addresses
	
	#256Counter
	#li      $v0, 4
	#la      $a0, Counter
	#syscall
	
	##========================>For individual iteration prints, switch this on
	#move    $a0, $t5
	#li  	$v0, 1
	#syscall
	#li      $v0, 4
	#la      $a0, comma
	#syscall
	##========================>For individual iteration prints, switch this on
	
	             
	j	loopinsertfinalarray
	 
	endloopinsertfinalarray:
	 
	
	followon:
	
	j 	loop			#jump loop
	
	
	ComputeNextState:
	li	$t5, 0		#Will store 0 if NEW and 1 if OLD
	checknewcounter:
	li	$k0, 2
	bne 	$k0, $s1, incrnew
	beq	$k0, $s1, chkNewFlg
	incrnew:
	addi 	$s1, $s1, 1 
	li 	$a0, 1
	beq     $t3, $a0, returnNew
	returnNew:
	li	$t5, 0
	j 	backtocomp
	chkNewFlg:
	li 	$a0, 1
	beq	$t3, $a0, resetNew
	bne   	$t3, $a0, checkoldcounter
	resetNew:
	li	$t3, 0
	li	$t4, 1
	li	$s2, 0
	j checkoldcounter
	checkoldcounter:
	li	$k0, 72
	bne	$s2, $k0, incrold
	beq	$s2, $k0, chkOldFlg
	incrold:
	addi 	$s2, $s2, 1
	li 	$a0, 1
	beq     $t4, $a0, returnOld
	returnOld:
	li	$t5, 1
	j 	backtocomp
	chkOldFlg:
	li 	$a0, 1
	beq	$t4, $a0, resetOld
	bne	$t4, $a0, checknewcounter
	resetOld:
	li	$t4, 0
	li	$t3, 1
	li 	$s1, 0
	j 	checknewcounter
		
	
main1:

	li     $t0, 0 		# $t0 = counter
	li     $t2, 1000000  #number of times we want to repeat the loop,  also equal to number of memory references
	li     $a1, 2147483647  	#Here you set $a1 to the max bound. This will take maximum 17 bits to represent
	li     $t4, 4
	la     $ra, finalarray
	
	li     $v0, 4                #Get block size from user
	la     $a0, promptBlock
	syscall
	li     $v0, 5
	syscall
	move $t7, $v0
	
	li     $v0, 4                #Get cache size from user
	la     $a0, promptCache
	syscall
	li     $v0, 5
	syscall
	
	move $t8, $v0
	  
	li     $k0, 0           #hit time counter
	li     $k1, 0           #miss penalty counter
	
	#from the above two statements, we need to calculate the number of blocks in the cache
	#Number of blocks in the cache = cache size / block size
	div    $t8 , $t7
	mflo   $s1	        #$s1 contains the number of blocks in cache

initlp: 
        #here compare if we have generated enough references
	beq    $t0, $t2, initdn 
        lw   $t6, 0($ra) 
	addi $ra, $ra, 4 
	addi  $t0, $t0, 1      # loop counter incremented
	
	
	#print it out
	#li    $v0, 4           # you can call it your way as well with addi 
	#la    $a0, reference     # load address of the string
	#syscall
	#move   $a0, $t6        #copy the corrected divisible by 4 number into #a0
	#li     $v0, 1          #1 print integer
    	#syscall
	
	#Now once we have the random byte address we want to calculate the block addr
	#Block addr = byte addr/ block size
	#lets start with a simple case of block size = 64 bytes, $t6 contains the perfectly divisible byte address
	div    $t6, $t7
	mflo   $s0             #quotient in $s0  
	
	#So we have to find the index now
	#index = Block Addr Mod (#of blocks in the cache)
	div    $s0,  $s1
	mfhi   $s2              #So now $s2 contains the index
	
	#having calculated the index, we want to calculate the tag. 
	#The tag is calculated as the byte address /(index*block size)
	multu  $s1,  $t7        #$s1 => index meaning number of blocks in cache, $t7 => block size and lo contains the product
	mflo   $s7              #move the lo into $s7, this stores the product
	div    $t6,  $s7        #byte address /(index*block size)
	mflo   $s6
	#So my tag is in $s6
	
	#print out everything
	#print it out
	#li    $v0, 4           # you can call it your way as well with addi 
	#la    $a0, index       # load address of the string
	#syscall
	#index
	#li    $v0, 1            
	#move  $a0, $s2     # load integer for index
	#syscall
	#print it out
	#li    $v0, 4           # you can call it your way as well with addi 
	#la    $a0, tag       # load address of the string
	#syscall
	#tag
	#li    $v0, 1            
	#move  $a0, $s6     # load integer for tag
	#syscall
	
	li $a3 , 0
	#here we find the tag value in our cache based on the index computed
	la $t1, tag_array     #put address of tag_array into $t1
	multu  $s2, $t4       # take the index and multiple it by 4
	mflo $t5
	add $a3, $t1, $t5     # we want to add this multiplied index to validity_array address and store in $t3
	lw $s5,  0($a3)
	
checkvaliditybit:
	la $t9, validity_array # put address of validity_array into $t9
	add $t3, $t9, $t5      # we want to add this multiplied index to validity_array address and store in $t3
	lw $s7,  0($t3)        #read it back for printing purpose
	bgtz $s7, matchthetags #if we found the validity bit set to 0, we have a miss, else we go ahead to match the tags
	
	## here we have a miss, so increement the miss counter appropriately but since we are calling tagmismatch which
	##anyways does the update tag, update validitybit so we can increase the miss penalty there 
	
	##update the tag
	b tagmismatch          #The tag mismatch code will also update the validity bit.
		
matchthetags:
	#Compare the tags 
	beq $s5, $s6, tagmatch
	bne $s5, $s6, tagmismatch
tagmatch:
	#if the tags match, we have to update the validity bit and increement the hit counter
	#So first lets increement the hit counnter
	#li    $v0, 4           	   
	#la    $a0, printhit       # print a hit
	#syscall
	
	addi $k0, $k0, 1        #counter increemented
        j updatevaliditybit
	
tagmismatch:
	#If we mismatch, we have to update the tag at the location with our tag value, 
	#also we have to set the validity bit and do time counter increements
	sw $s6,  0($a3)
	li $s5, 0
	lw $s5,  0($a3)
	#print it out
	
	#li    $v0, 4           	   
	#la    $a0, printmiss       # print a hit
	#syscall
	
	##here we have to increement the miss penalty
	addi $k1, $k1, 1        #counter increemented
	
	b updatevaliditybit
	
updatevaliditybit:
	la $t9, validity_array # put address of validity_array into $t9
	add $t3, $t9, $t5      # we want to add this multiplied index to validity_array address and store in $t3
	li $s5, 1              #we want to store 1 in validity bit
	sw $s5,  0($t3)         #store
	li $s5, 0
	lw $s5,  0($t3)        #read it back for printing purpose
	
	b  initlp     
initdn: 
	#print it out
	li    $v0, 4           		# you can call it your way as well with addi 
	la    $a0, hitcountervalue      # print hit counter string
	syscall
	#print hit counter value
	li    $v0, 1            
	move  $a0, $k0     # load hit counter value in $a0
	syscall
	
	#print it out
	li    $v0, 4           		 
	la    $a0, misspenaltycountervalue      # print miss counter string
	syscall
	#print miss penalty counter value
	li    $v0, 1            
	move  $a0, $k1     # load miss penalty counter value in $a0
	syscall
	
	#calculate Effective Memory access time
	div   $t7,$t4
	mflo  $t1          #miss penalty
	add   $t1,$t1,1
	multu $k1,$t1
	mflo  $t9
	
	add   $t9,$t9,$k0
	mtc1  $t9, $f0
	mtc1  $t2, $f1
	cvt.s.w $f2, $f0
	cvt.s.w $f4, $f1
	div.s $f6,$f2, $f4
	#cvt.d.s $f8, $f6
	
	#print the Effective Memory Access Time
	li     $v0, 4
	la     $a0, eat
	syscall
	li     $v0, 2
	mov.s   $f12, $f6
	syscall
	
	
	li    $v0, 10
	syscall
