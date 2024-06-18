.global _start
_start:
    movia r6, 0xFF200000 # LED PIT/OUTPUT
    movia r7, 0xFF200050 # BUTTON PIT/INPUT
        stwio r0, 0(r6)      # Turn off all LEDs, write 0 to LED
        stwio r0, 12(r7) #?


wait:
    ldwio r11, 12(r7)     # Read BUTTON PIT EDGE


    
    movi r12, 1            # Store mask of key0
    and r10, r11, r12      # Check bit for KEY0
    beq r10, r12, key0_pressed    # KEY0 pressed 
    
    movi r12, 2            # Store mask of key1
    and r10, r11, r12      # Check bit for KEY1
    beq r10, r12, key1_pressed    # KEY1 pressed 
    
    movi r12, 4            # Store mask of key2
    and r10, r11, r12      # Check bit for KEY2
    beq r10, r12, key2_pressed    # KEY2 pressed 
    
    movi r12, 8            # Store mask of key3
    and r10, r11, r12      # Check bit for KEY3
    beq r10, r12, key3_pressed    # KEY3 pressed 
    
    br wait


key0_pressed:
        movi r11, 1
        stwio r11, 12(r7)        #Clear edge
    call wait_release
    movi r4, 1
    stwio r4, 0(r6) 
    br wait


key1_pressed:
        movi r11, 2
        stwio r11, 12(r7)        #Clear edge
    call wait_release
    call increase
    br wait


key2_pressed:
        movi r11, 4
        stwio r11, 12(r7)        #Clear edge
    call wait_release
    call decrease
    br wait


key3_pressed:
        movi r11, 8
        stwio r11, 12(r7)        #Clear edge
    call wait_release
    call blank_and_wait
        call wait_release
    movi r8, 1
    stwio r8, 0(r6)
    
    br wait
        
blank_and_wait:
loop:
    stwio r0, 0(r6)      # Turn off all LEDs, write 0 to LED
    ldwio r11, 12(r7)    # Read BUTTON PIT EDGE
        stwio r11, 12(r7)
    andi r10, r11, 15    # Check bit for any key
    beq r10, r0, loop   # Wait for any key to be pressed 
        ret
    




wait_release:
    ldwio r8, 0(r7)           # Read pushbutton state
    andi r9, r8, 15           # Check all buttons at once
    bne r9, r0, wait_release  # Wait until all buttons are released
        
    ret


increase:
    ldwio r8, 0(r6)           # Load current LED number
    movi r9, 15                # Temporary store 15 in r9
    blt r8, r9, add            # Increment if the LED value in r8 is less than 15
    ret


add: 
    addi r8, r8, 1
    stwio r8, 0(r6)
    ret


decrease:
    ldwio r8, 0(r6)           # Load current LED number
    movi r9, 1                 # Temporary store 1 in r9
    bgt r8, r9, sub            # Decrement if the LED value in r8 is greater than 1
    ret


sub: 
    subi r8, r8, 1
    stwio r8, 0(r6)
    ret