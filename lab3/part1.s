/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:

	movia r8, InputWord 	#Store adress of InputWord in r8
	movia r9, Answer 	#Store adress of result in r9

	ldw r10,(r8) 		#Load word into r10
	movi r11, 0		#Initialize ounter for number of ones
	movi r12, 32		#Counter that will reach 0 once all 32 bits are seen

count:
	

	andi r13, r10, 0x0001 	#Store the least siginigicant bit of the word in r13
	srai r10, r10, 1		#Shift right bits in r10 (which stores word)
	add r11, r13, r11		#If the current bit is 1, the counter goes up by 1, otherwise it adds 0 and stays the same
	
	subi r12, r12, 1 		#Decriment the counter
	
	bne r12, r0, count		#Keep counting until counter reaches 0

load_result: stw r11, 0(r9)   # Store the value in r11 at anwser

endiloop: br endiloop

InputWord: .word 0x4a01fead

Answer: .word 0
	
	

