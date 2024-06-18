.global _start
                .equ      TIMER_BASE, 0xFF202000
                .equ      COUNTER_DELAY, 25000000
                .equ          LEDs, 0xff200000
                .equ KEY_BASE, 0xFF200050


_start:
movia       r10,KEY_BASE                # set r10 to base KEY port
movia       r11,LEDs                        # set r11 to base of LEDR port
movia       r20, TIMER_BASE      # base address of timer




            stwio      r0, 0(r20)         # clear the TO (Time Out) bit in case it is on
            movia      r8, COUNTER_DELAY    # load the delay value
            srli       r9, r8, 16           # shift right by 16 bits
            andi       r8, r8, 0xFFFF       # mask to keep the lower 16 bits
            stwio      r8, 0x8(r20)         # write to the timer period register (low)
            stwio      r9, 0xc(r20)         # write to the timer period register (high)
            movi       r8, 0b0110           # enable continuous mode and start timer
            stwio      r8, 0x4(r20)         # write to the timer control register to 
                                                                                        # and go into continuous mode
                                                                                        


tloop:           
again:
          movi r13, 0
                  movi r15,255 #will count up to this 
                  stwio r13,0(r11) #value will be stored in LEDS


poll:          ldwio r12, 0xC(r10)                # load edge capture reg
                  andi  r12,r12,0x1                 #check for key 0
                  bne        r12, r0,stopcount1  # if key 0 is pressed go to action1
                  
                  ldwio r12, 0xC(r10)     # load edge capture reg
                  andi  r12,r12,0x2                 #check for key 1
                  bne        r12, r0,stopcount2 # if key 1 is pressed go to action1
                  
                  ldwio r12, 0xC(r10) #same for key 2
                  andi  r12,r12,0x4                 
                  bne        r12, r0,stopcount3                 
                  
                  ldwio r12, 0xC(r10) #same for key 3
                  andi  r12,r12,0x8                 
                  bne        r12, r0,stopcount4
        
ploop:     ldwio      r8, 0x0(r20)         # read the timer status register
            andi       r8, r8, 0b1          # mask the TO bit
            beq        r8, r0, ploop     # if TO bit is 0, wait
                        #otherwise when T0 bit is 1, set it to zero again for recounting: 
            stwio      r0, 0x0(r20)         # clear the TO bit
                        beq        r13,r15, again #if equal to 255 start again from 0 
                        addi       r13, r13, 1 #keep adding 1
                        stwio r13,0(r11) #store into LED
                        
                        
                        br poll 
                        
                        
stopcount1:
                  movi  r12, 0x1                # turn off edge capture bit
                  stwio r12, 0xC(r10)   
                  stwio r13,0(r11)
                 #now check again if key is pressed 
check1:         ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x1                 
                 bne        r12, r0, key_pressed1
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x2                 
                 bne        r12, r0, key_pressed2
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x4         
                 bne        r12, r0, key_pressed3
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x8         
                 bne        r12, r0, key_pressed4
                 br   check1
                 
                                          
stopcount2:
                  movi  r12, 0x2                # turn off edge capture bit
                  stwio r12, 0xC(r10)
                  stwio r13,0(r11)
                                   #now check again if key is pressed 
check2:         ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x1                 
                 bne        r12, r0, key_pressed1
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x2                 
                 bne        r12, r0, key_pressed2
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x4         
                 bne        r12, r0, key_pressed3
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x8         
                 bne        r12, r0, key_pressed4
                 br   check2
                                                        
stopcount3:
                  movi  r12, 0x4                # turn off edge capture bit
                  stwio r12, 0xC(r10)
                  stwio r13,0(r11)
                                   #now check again if key is pressed 
check3:         ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x1                 
                 bne        r12, r0, key_pressed1
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x2                 
                 bne        r12, r0, key_pressed2
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x4         
                 bne        r12, r0, key_pressed3
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x8         
                 bne        r12, r0, key_pressed4
                 br   check3
                                                        
stopcount4:
                  movi  r12, 0x8                # turn off edge capture bit
                  stwio r12, 0xC(r10)
                  stwio r13,0(r11)
                 #now check again if key is pressed 
check4:         ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x1                 
                 bne        r12, r0, key_pressed1
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x2                 
                 bne        r12, r0, key_pressed2
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x4         
                 bne        r12, r0, key_pressed3
                 ldwio r12, 0xC(r10)                # load edge capture reg
                 andi  r12,r12,0x8         
                 bne        r12, r0, key_pressed4
                 br   check4
                 
                  
key_pressed1: 
    #write 1 back into the edge capture reg and start counting again 
        movi  r12, 0x1                # turn off edge capture bit
    stwio r12, 0xC(r10)
        br  ploop #start showing increase again 
        
key_pressed2:
movi  r12, 0x2        # turn off edge capture bit
    stwio r12, 0xC(r10)
        br   ploop
   
   
 key_pressed3:
movi  r12, 0x4        # turn off edge capture bit
    stwio r12, 0xC(r10)
        br   ploop
   
 key_pressed4:
movi  r12, 0x8        # turn off edge capture bit
    stwio r12, 0xC(r10)
        br   ploop