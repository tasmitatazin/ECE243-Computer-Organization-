/******************************************************************************
 * Write an interrupt service routine
 *****************************************************************************/
.section .exceptions, "ax"
IRQ_HANDLER: #et, 
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 52          # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)
                stw                r2, 12(sp)
                stw                r4, 16(sp)
                stw                r5, 20(sp)
                stw                r6, 24(sp)
                stw                r7, 28(sp)
                stw                r8, 32(sp)
                stw                r9,        36(sp)
                stw                r22,40(sp)
                stw                r23,44(sp)


        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts


SKIP_EA_DEC: #r20
        stw     ea, 48(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        subi    sp,sp,4
                stw     ra, 0(sp)
                call    KEY_ISR             # if yes, call the pushbutton ISR
        ldw     ra,0(sp)
                addi    sp,sp,4
                
END_ISR:        #et,r20,r22,r23
                movia r22,KEYs #this is to clear the edge capture register once the interrupt is done 
                ldwio r23,0xC(r22)
                stwio r23,0xC(r22)
                
                ldw                r2, 12(sp)
                ldw                r4, 16(sp)
                ldw                r5, 20(sp)
                ldw                r6, 24(sp)
                ldw                r7, 28(sp)
                ldw                r8, 32(sp)
                ldw                r9,        36(sp)
                ldw                r22,40(sp)
                ldw                r23,44(sp)
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     ea, 48(sp)
        addi    sp, sp, 52          # restore stack pointer
        eret                        # return from exception


KEY_ISR: #r6,r7,r4,r8


      movia r6, KEYs    # address of LEDS
      movia r7, HEXs  
      ldwio r4, 0xC(r6)         # can also load the current state keys edge capture 
      #now we have to display on the hexdisplay if the button is pressed and black it if pressed      #again 
      #checking individually which key was pressed ?
      movi  r8, 0b0001 #if key 0 is pressed
      beq   r4, r8, KEY0_pressed
          movi r8, 0b0010
          beq  r4,r8, KEY1_pressed
      movi r8, 0b0100
          beq  r4,r8, KEY2_pressed
      movi r8, 0b1000
          beq  r4,r8, KEY3_pressed


KEY0_pressed:  # using r9,r4,r5


movia r9,Key0_argument #r9 is pointing to that memory location 
ldw         r9,0(r9) #Loading that value into r9 
xori r9, r9, 0x10 #toggles the 4th bit 
mov r4,r9 #storing it in r4 so we can send it to the hex subroutine 
mov r5,r0 #hex display should be the 0th display 
subi sp,sp,4
stw ra,0(sp) #storing ra on the stack 
call HEX_DISP
ldw ra,0(sp)
addi sp,sp,4


movia r4,Key0_argument
stw        r9,0(r4) #storing the current value in the memory again 
ret 


KEY1_pressed:  #r9,r4,r5


movia r9,Key1_argument
ldw         r9,0(r9)
xori r9, r9, 0x10 #toggles the 4th bit 
mov r4,r9
movi r5,1
subi sp,sp,4
stw ra,0(sp)
call HEX_DISP
ldw ra,0(sp)
addi sp,sp,4


movia r4,Key1_argument
stw        r9,0(r4)
ret 


KEY2_pressed:  #r9,r4,r5


movia r9,Key2_argument
ldw         r9,0(r9)
xori r9, r9, 0x10 #toggles the 4th bit 
mov r4,r9
movi r5,2
subi sp,sp,4
stw ra,0(sp)
call HEX_DISP
ldw ra,0(sp)
addi sp,sp,4


movia r4,Key2_argument
stw        r9,0(r4)
ret 


KEY3_pressed:  #r9,r4,r5


movia r9,Key3_argument
ldw         r9,0(r9)
xori r9, r9, 0x10 #toggles the 4th bit 
mov r4,r9
movi r5,3
subi sp,sp,4
stw ra,0(sp)
call HEX_DISP
ldw ra,0(sp)
addi sp,sp,4


movia r4,Key3_argument
stw        r9,0(r4)
ret 




.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030
# r8, r6,r4,r5,r7
HEX_DISP:   movia    r8, BIT_CODES         # starting address of the bit codes
            andi     r6, r4, 0x10           # get bit 4 of the input into r6
            beq      r6, r0, not_blank 
            mov      r2, r0
            br       DO_DISP
not_blank:  andi     r4, r4, 0x0f           # r4 is only 4-bit
            add      r4, r4, r8            # add the offset to the bit codes
            ldb      r2, 0(r4)             # index into the bit codes


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
END:                        
                        ret
                        
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
                        .byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
                        .byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
                        .byte     0b00111001, 0b01011110, 0b01111001, 0b01110001


            
                






/*********************************************************************************
 * set where to go upon reset
 ********************************************************************************/
.section .reset, "ax"
        movia   r8, _start
        jmp    r8 # why do we need this im not sure 


/*********************************************************************************
 * Main program
 ********************************************************************************/
.text
.global  _start
_start:
.equ LEDs, 0xff200000 
.equ KEYs, 0xff200050
.equ HEXs, 0xff200020


movia sp, 0x20000
movia r2, KEYs
movi r3, 0b01    #to store the pie and supervisor bit 
movi r4, 0xf     # need to affect bit 0 1 2 3  using r4 of several registers
stwio r4, 0xC(r2)         
# this clears the edge capture bit for KEY0 1 2 3 if it was on, writing into the edge capture #register
stwio r4, 8(r2)        # turn on the interrupt mask register bit 0 for KEY 0 1 2 3 so that this causes
 # an interrupt from the KEYs to go to the processor when button released
 movi r5, 0x2                        # need to turn on bit 1 below 0010 
 wrctl ctl3, r5                 # ctl3 also called ienable reg - bit 1 enables interupts for IRQ1->buttons
 wrctl ctl0, r3                # ctl 0 also called status reg - bit 0 is Proc Interrupt Enable (PIE) bit; 
 # bit 1 is the User/Supervisor bit = 0 means supervisor 




loop: 


br loop #stays in this loop forever 


#below are the memories assigned for each of the keys , each memory location stores the current state of the hec displays (if blank or not) 
.section .data
Key0_argument: .word 0x10  #currently storing a zero because 5th bit is 1 (starting from 1)
Key1_argument: .word 0x11 #currently storing a zero because 5th bit is 1 (starting from 1)
Key2_argument: .word 0x12  #currently storing a zero because 5th bit is 1 (starting from 1)
Key3_argument: .word 0x13 #currently storing a zero because 5th bit is 1 (starting from 1)