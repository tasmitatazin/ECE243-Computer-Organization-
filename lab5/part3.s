.equ LED_BASE,         0xFF200000
.equ BUTTON_BASE,      0xFF200050


.equ TIMER0_BASE,      0xFF202000
.equ TIMER0_STATUS,    0
.equ TIMER0_CONTROL,   4
.equ TIMER0_PERIODL,   8
.equ TIMER0_PERIODH,   12


 # Change for board
 .equ TICKSPERSEC,     50000000
.equ TICKSPERTIME,     12500000
.section .exceptions, "ax"


#Make room on stack for registers
        addi sp, sp, -24
        stw r8, 0(sp)
        stw r9, 4(sp)
        stw r10, 8(sp)
        stw     et, 12(sp)
    stw     ra, 16(sp)
        
        
         rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts


        SKIP_EA_DEC:
        
     stw     ea, 20(sp)
         #Check button edges to see if button caused it
           andi    r8, et, 0x2        # check if interrupt is from pushbuttons
        movi r9, 0x2
                beq     r8, r9, wasbutton   # if button, branch to wasbutton


      andi    r8, et, 0x1        # check if interrupt is from timer
        movi r9, 0x1
                beq     r8, r9, wastimer    # if timer, branch to wastimer
                br exit #was neither
wastimer:
        movia r8, TIMER0_BASE
        stwio r0, 0(r8) #clear Status TO bit to turn off the interrupt 
        
counter:
        movia   r8, RUN           # load run
        ldw r9, 0(r8)
        beq r9, r0, exit         #if RUN is 0, counting is paused


        movia   r8, COUNT           # get current count
        ldw r9, 0(r8)


        movi r8, 1023
        #Check if LEDs reach max value (2^10 - 1) = 1023
        beq r8, r9, maxed_out
        
        movia   r8, COUNT        #Incriment count
        addi r9, r9, 1
        stw r9, 0(r8)
        br exit


maxed_out:
        movia   r8, COUNT           # get currrent count and reset to 0
        stw r0, 0(r8)
        br exit


        
wasbutton:
              movia   r8, BUTTON_BASE        # Button base address
              movi r9, 15   # make EDGE register is all clear


              stwio r9, 12(r8) # reset EDGE bits


        
        movia   r10, RUN           # load run
        ldw r9, 0(r10)
        xori r9, r9, 1        #Flip the number for run
        stw r9, 0(r10)        #Update RUN in memory


exit:
        ldw r8, 0(sp)
        ldw r9, 4(sp)
        ldw r10, 8(sp)
        ldw     et, 12(sp)
    ldw     ra, 16(sp)
        ldw     ea, 20(sp)
        addi sp, sp, 24
        eret


.text
.global  _start
_start:
    /* Set up stack pointer */
                movia sp, 0x200000
    call    CONFIG_TIMER        # configure the Timer
    call    CONFIG_KEYS         # configure the KEYs port
    /* Enable interrupts in the NIOS-II processor */
        movi r8, 1
        wrctl ctl0, r8 # enable ints globally


    movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
LOOP:
        movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
    ldw     r10, 0(r9)          # global variable
    stwio   r10, 0(r8)          # write to the LEDR lights
    br      LOOP


CONFIG_TIMER:    
    movia   r8, TIMER0_BASE        # Load timer base into r8
    movi    r9, 0x8                # Stop the timer
    stwio   r0, 0(r8)              # Clear TO
    stwio   r9, 4(r8)              # Stop the timer


    movi    r9, %lo(TICKSPERTIME)  # Store the lower bits of the period in r9
    stwio   r9, TIMER0_PERIODL(r8) # Load period into timer


    addi    r9, r0, %hi(TICKSPERTIME)   # Store the higher bits of the period in r9
    stwio   r9, TIMER0_PERIODH(r8)      # Load period into timer


    movi    r9, 0x7                # 0x7 = 0111, so we write 1 to START, CONT, and ITO
    stwio   r9, TIMER0_CONTROL(r8)     # Tell the counter to start over automatically and start counting and interrupt when done
        
        movi r8, 1
    wrctl ctl3, r8 # enable ints for IRQ0/timer


        ret


CONFIG_KEYS:       
        movia r8, BUTTON_BASE #buttons base
    movi r9, 0xF
        stwio r9, 12(r8) #Clear edges
        stwio r9, 8(r8)  # set mask bits
        rdctl r10, ctl3
        ori r10, r10, 2
        wrctl ctl3, r10 # enable ints for IRQ1/buttons
        ret




.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer


.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT


.end