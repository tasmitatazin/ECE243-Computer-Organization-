.text
/* Program to Count the number of 1's and Zeroes in a sequence of 32-bit words,
and determines the largest of each */

.global _start
_start:

	movia r8, TEST_NUM 	#Store adress of TestNum in r8

	movi r10, 0	#Store current ones
	movi r11, 0	#Store greatest 1s

	movi r12, 0	#Store current 1s
	movi r13, 0	#Store greatest 0s

count_loop:
	ldw r4,(r8) 		#Load word into r4
	beq r4, r0, finish #Fnish if list is finished
	
	call ones

	mov r10, r2 #r2 has return value, save in r10
	movi r2, 0xFFFFFFFF
	xor r4, r4, r2
	
	call ones

	mov r12, r2 #r2 has return value, save in r12

	bge r10, r11, update_1
	bge r12, r13, update_0
	br update_loop

update_1:
mov r11, r10
bge r12, r13, update_0
br update_loop

update_0:
mov r13, r12

update_loop:
	addi r8, r8, 4		#Move to next word
	br count_loop
	
ones:
	movi r2, 0		#Initialize ounter for number of ones
	movi r5, 32		#Counter that will reach 0 once all 32 bits are seen

	mov r6, r4		#Copies r4 which has word into r6
	

loop:
	
	andi r3, r6, 0x0001 		#Store the least siginigicant bit of the word in r3
	srai r6, r6, 1		#Shift right bits in r6 (which stores word)
	add r2, r3, r2			#If the current bit is 1, the counter goes up by 1, otherwise it adds 0 and stays the same
	
	subi r5, r5, 1 		#Decriment the counter
	
	bne r5, r0, loop		#Keep counting until counter reaches 0

	ret

finish: movia r9, LargestOnes #Store largest ones and 0s in memory
		stw r11, 0(r9)
		movia r9, LargestZeroes
		stw r13, 0(r9)
		br endiloop
		

endiloop: 
	.equ LEDs, 0xff200000
	movia r25, LEDs
	stwio r11, (r25)
	
	
	call delay_loop
	
	
	stwio r13, (r25)
	call delay_loop
	
	br endiloop
	
delay_loop:
	movia r2, Delay
	ldw r4, (r2)
    movi r2, 0

count_up:
    addi r2, r2, 1
    blt r2, r4, count_up
    ret

.data
TEST_NUM:  .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            .word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0
Delay: .word 9999800
	
	


