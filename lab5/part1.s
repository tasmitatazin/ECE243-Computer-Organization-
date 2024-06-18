﻿.global _start
_start:
        
/*    Subroutine to display a four-bit quantity as a hex digits (from 0 to F) 
      on one of the six HEX 7-segment displays on the DE1_SoC.
*
 *    Parameters: the low-order 4 bits of register r4 contain the digit to be displayed
                  if bit 4 of r4 is a one, then the display should be blanked
 *                      the low order 3 bits of r5 say which HEX display number 0-5 to put the digit on
 *    Returns: r2 = bit patterm that is written to HEX display
 */


.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030
startagain:
movi sp, 0x2000




movi r10, 17 # will count upto hex f and 16 will make the 5th bit zero so it will go blank 
movi r11, 6 #will count upto 6 for 6 hex displays 
movi  r5, 0 #starts with hex 0 


enter_loop2:
movi r4, 0 # will display 0 to 15 and come back here 
hex:
call HEX_DISP 
delay_loop: #delay for the number to be displayed on the hex 
movia r12, Delay
ldw r13, (r12)
movi r12, 0
count_up:
addi r12, r12, 1
blt r12, r13, count_up 
addi  r4, r4, 1 #count up 
bne r4, r10, hex #if not equal to 15 redo 
addi r5,r5,1  # increment hex display number one after another 
beq r5, r11 , startagain #redo the whole thing is numbers are done on the last hex 
br enter_loop2 # if not the last hex display then move on the next hex display then start again from 0 












HEX_DISP: 
#putting the values of r4 and r5 on the stack 
        addi sp, sp, -8
            stw r4, 0(sp)
            stw r5, 4(sp)


        movia    r8, BIT_CODES         # starting address of the bit codes
            andi     r6, r4, 0x10           # get bit 4 of the input into r6
            beq      r6, r0, not_blank 
            mov      r2, r0
            br       DO_DISP
not_blank:  andi     r4, r4, 0x0f           # r4 is only 4-bit
            add      r4, r4, r8            # add the offset to the bit codes
            ldb      r2, 0(r4)     in        # index into the bit codes


#Display it on the target HEX display
DO_DISP:    
                        movia    r8, HEX_BASE1         # load address
                        movi     r6,  4
                        blt      r5,r6, FIRST_SET      # hex4 and hex 5 are on 0xff200030
                        sub      r5, r5, r6            # if hex4 or hex5, we need to adjust the shift
                        addi     r8, r8, 0x0010        # we also need to adjust the address
FIRST_SET:
                        slli     r5, r5, 3             # hex*8 shift is needed
                        addi     r7, r0, 0xff          # create bit mask so other values are not corrupted
                        sll      r7, r7, r5 
                        addi     r4, r0, -1
                        xor      r7, r7, r4  
                            sll      r4, r2, r5            # shift the hex code we want to write
                        ldwio    r5, 0(r8)             # read current value       
                        and      r5, r5, r7            # and it with the mask to clear the target hex
                        or       r5, r5, r4                   # or with the hex code
                        stwio    r5, 0(r8)                       # store back
                        ldw      r4, 0(sp)
                        ldw      r5, 4(sp)
                        addi     sp, sp, 8
END:                        
                        ret
                        
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
                        .byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
                        .byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
                        .byte     0b00111001, 0b01011110, 0b01111001, 0b01110001
Delay: .word 900000
        




            .end