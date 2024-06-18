/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:

	movia r8, InputWord 	#Store adress of InputWord in r8
	movia r9, Answer 	#Store adress of result in r9

	ldw r4,(r8) 		#Load word into r2
	call ones
	br endiloop
	
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

done: ret

endiloop: br endiloop

InputWord: .word 0x4a01fead

Answer: .word 0
	
	

