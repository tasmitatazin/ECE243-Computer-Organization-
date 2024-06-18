.text  # The numbers that turn into executable instructions
.global _start
_start:

/* r13 should contain the grade of the person with the student number, -1 if not found */
/* r10 has the student number being searched */


	movia r10, 345018		# r10 is where you put the student number being searched for

#first gonna find the index number of the student and them count the index from 
#grades section as well
     mov r11, r0
	 movi r12, Snumbers #r12 points to the student numbers
	 ldw  r14,(r12) #whatever is in r12 will be placed in r14 
check:
     beq  r14, r0, not_found  #if reached end of list and snumber is not there
	 beq  r14, r10 , find_grade #if its equal to the number then branch to finding the grade
	 #beq  r14, r0, not_found  #if reached end of list and snumber is not there
	 addi r11,r11,1
	 addi r12,r12,4
	 ldw  r14,(r12) #go to the next student number if not equal 
	 br   check #check again if its the same or not
	 
	 
find_grade: # if index is found and stored in r11 
    movi  r8, 0
	movi  r15, Grades
	ldb   r16,(r15) #grade being stored in r16 

checkagain:
    beq   r8, r11, found #if index found
	addi  r8,r8,1 #otherwise add one go to next index
	addi  r15,r15,1
	ldb   r16,(r15) #grade being stored in index r16 
	br    checkagain 

found: #store the grade in r13
   mov   r13, r16
   movi   r9,result
   stb   r13,(r9)
   movia r25, LEDs
    stwio r13, (r25)
	   br    iloop
    
not_found: 
   movi  r13, -1
   movi   r9,result
   stb   r13,(r9)
   movia r25, LEDs
    stwio r13, (r25)
	   br    iloop

iloop: br iloop


.data  	# the numbers that are the data 
.equ LEDs, 0xFF200000

/* result should hold the grade of the student number put into r10, or
-1 if the student number isn't found */ 

result: .byte 0

.align 2
		
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .byte 99, 68, 90, 85, 91, 67, 80
        .byte 66, 95, 91, 91, 99, 76, 68  
        .byte 69, 93, 90, 72
	
	
