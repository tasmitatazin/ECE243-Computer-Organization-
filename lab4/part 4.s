.equ TIMER0_BASE,      0xFF202000
.equ TIMER0_STATUS,    0
.equ TIMER0_CONTROL,   4
.equ TIMER0_PERIODL,   8
.equ TIMER0_PERIODH,   12
.equ TIMER0_SNAPL,     16
.equ TIMER0_SNAPH,     20


.equ LED_BASE,         0xFF200000
.equ BUTTON_BASE,      0xFF200050


.equ TICKSPERSEC,      100000000                #Change for desoc board!!!!!!!!!!
.equ TICKSPERHUND,     1000000     # 0.01 seconds in ticks, Change for desoc board!!!!!!!!!!


.global _start
_start:


        movia   r16, TIMER0_BASE
    movia   r17, LED_BASE
    movia   r18, BUTTON_BASE
        
         stwio r0, 0(r17)               # Turn off all LEDs
         movi  r9, 0x8                   # stop the counter  ????/
     stwio r9, TIMER0_CONTROL(r16) #????


      # Set the period registers to count 0.01 sec
      movi r9, %lo (TICKSPERHUND) #????


      stwio r9, TIMER0_PERIODL(r16)


      addi r9, r0, %hi(TICKSPERHUND)


      stwio r9, TIMER0_PERIODH(r16)


        # tell the counter to start over automatically and start counting
      movi  r9, 0x6                   # 0x6 = 0110 so we write 1 to START and to CONT
      stwio r9, TIMER0_CONTROL(r16)
          
          movi r13, 1 #Current counter status, 1 = running, 0 = stoped
          movi r14, 0         #Store number of ms
          movi r15, 0        #Store num of sec
          
clock_loop:
    # Check for button presses
        ldwio   r11, 12(r18)            # Read BUTTON PIT EDGE


    movi    r12, 1                  # Store mask of key0
    and     r10, r11, r12           # Check bit for KEY0
    beq     r10, r12, key_pressed   # KEY0 pressed 


    movi r12, 2            # Store mask of key1
    and r10, r11, r12      # Check bit for KEY1
    beq r10, r12, key_pressed    # KEY1 pressed 
    
    movi r12, 4            # Store mask of key2
    and r10, r11, r12      # Check bit for KEY2
    beq r10, r12, key_pressed    # KEY2 pressed 
    
    movi r12, 8            # Store mask of key3
    and r10, r11, r12      # Check bit for KEY3
    beq r10, r12, key_pressed    # KEY3 pressed 
        
    call    update_clock            # Update clock if running
        
    br      clock_loop
        
key_pressed:
        stwio   r11, 12(r18)            # Clear edge
        
    call    wait_release            # Wait for key release
    call    change_clock_state      # Pause/Unpause clock
        movi r9,  1
    xor r13, r13, r9                  # Toggle clock state
    br      clock_loop
        
wait_release:
    wait_loop:
        ldwio   r8, 0(r18)          # Read pushbutton state
        andi    r9, r8, 15          # Check all buttons at once
        bne     r9, r0, wait_loop   # Wait until all buttons are released


    done_wait: ret
        
change_clock_state:
    beq     r13, r0, unpause
    # Stop timer
    movi    r9, 0x8                 # Set STOP bit
    stwio   r9, TIMER0_CONTROL(r16)
    ret
        
unpause:
    # Start timer again
    movi    r9, 0x6                 # Set CONT and START bits
    stwio   r9, TIMER0_CONTROL(r16)
    ret




update_clock:
    beq     r13, r0, clock_not_elapsed          # If clock is paused, do nothing


    # Check if 0.01 seconds have elapsed
    ldwio   r9, TIMER0_STATUS(r16)
    andi    r9, r9, 0x1             # Check TO bit
    beq     r9, r0, clock_not_elapsed #Do nothing, counter is not done


    # Clear TO bit
    stwio   r0, TIMER0_STATUS(r16)


        #If 99 ms done, update number of seconds
    movi r9, 99
    beq r14, r9, one_second_done
        
        #Increase ms count
        addi r14, r14, 1
        
        #Update LEDs for ms
        slli r9, r15, 7                #Shift the bits in seconds to the last 3 bits among the 10LEDs
        add r9,r14, r9 
        stwio r9, 0(r17)
        
        
        ret
        
one_second_done:
        movi r14, 0 #Reset ms count
        
        #Check if 8s done
        movi r9, 8
        beq r15, r9, eight_done
        
        addi r15, r15, 1
        #Update LEDs for ms
        stwio r0, 0(r17)      # Turn off all LEDs, write 0 to LEDs
        
        #Update LEDs for seconds
        slli r9, r15, 7                #Shift the bits in seconds to the last 3 bits among the 10LEDs
        stwio r9, 0(r17)


        
        ret
        
eight_done:
        movi r15, 0 #Reset seconds


        stwio r0, 0(r17)      # Turn off all LEDs, write 0 to LED
        ret


clock_not_elapsed:
   # Clock is paused or no time passed, do nothing


    ret