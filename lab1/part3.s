 
.global _start
_start:


#compute sum from 1 to 30 and store in reg 12 

           movi r8,1 #contains the starting value 
		   movi r9,31 #we will use to compare 
           movi r12, 0 #contains the sum of the numbers 
loop:	   beq  r8,r9,infinite
		   
		   add  r12,r12, r8 
		   addi r8,r8, 1
		   br   loop
		   
infinite:  br   infinite