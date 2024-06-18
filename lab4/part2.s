.global _start


                .equ KEY_BASE, 0xFF200050
                .equ LEDs, 0xFF200000
                .equ      COUNTER_DELAY, 500000
                
_start:   movia r8,KEY_BASE                # set r8 to base KEY port
                   movia r9,LEDs                        # set r9 to base of LEDR port


again:
          movi r13, 0
                  movi r15,255 #will count up to this 
                  stwio r13,0(r9) #value will be stored in LEDS


poll:          ldwio r11, 0xC(r8)                # load edge capture reg
                  andi  r11,r11,0x1                 #check for key 0
                  bne        r11, r0,stopcount1  # if key 0 is pressed go to action1
                  
                  ldwio r11, 0xC(r8)     # load edge capture reg
                  andi  r11,r11,0x2                 #check for key 1
                  bne        r11, r0,stopcount2 # if key 1 is pressed go to action1
                  
                  ldwio r11, 0xC(r8) #same for key 2
                  andi  r11,r11,0x4                 
                  bne        r11, r0,stopcount3                 
                  
                  ldwio r11, 0xC(r8) #same for key 3
                  andi  r11,r11,0x8                 
                  bne        r11, r0,stopcount4 
                  
#no key pressed so we enter this delay loop 
                  
DO_DELAY: 
movia r14, COUNTER_DELAY 


SUB_LOOP:
subi r14, r14, 1
bne r14, r0, SUB_LOOP


addi r13, r13, 1 #after 0.25 seconds add one 
stwio r13,0(r9)
bne  r13, r15, poll #until 255 reached, check again for edge capture reg
br  again #if 255 reached, start again from 0




                 
stopcount1:
                  movi  r12, 0x1                # turn off edge capture bit if key 0 is pressed
                  stwio r12, 0xC(r8)    #by storing a one into that 
                  stwio r13,0(r9)       #show on LED current counter value
                 #now check again if key is pressed so counting can start again
check1:         ldwio r11, 0xC(r8)                # load edge capture reg
                 andi  r11,r11,0x1                 #check for key 0 
                 bne        r11, r0, key_pressed1 #if key 0 is pressed, go to keypressed 1
                 ldwio r11, 0xC(r8)                
                 andi  r11,r11,0x2                 #check for key 2
                 bne        r11, r0, key_pressed2 #if key 2 is pressed, go to keypressed 2
                 ldwio r11, 0xC(r8)                # same for key 3
                 andi  r11,r11,0x14         
                 bne        r11, r0, key_pressed3
                 ldwio r11, 0xC(r8)                # same for key 4
                 andi  r11,r11,0x18         
                 bne        r11, r0, key_pressed4
                 br   check1 #keep checking until a key is pressed again 
                 
                                          
stopcount2:
                  movi  r12, 0x2                # turn off edge capture bit
                  stwio r12, 0xC(r8)
                  stwio r13,0(r9)
                                   #now check again if key is pressed
check2:         ldwio r11, 0xC(r8)                #does the exact same thing as check 1
                 andi  r11,r11,0x1                 
                 bne        r11, r0, key_pressed1
                 ldwio r11, 0xC(r8)                
                 andi  r11,r11,0x2                 
                 bne        r11, r0, key_pressed2
                 ldwio r11, 0xC(r8)                
                 andi  r11,r11,0x14         
                 bne        r11, r0, key_pressed3
                 ldwio r11, 0xC(r8)                
                 andi  r11,r11,0x18         
                 bne        r11, r0, key_pressed4
                 br   check2
                                                        
stopcount3:
                  movi  r12, 0x4                # turn off edge capture bit
                  stwio r12, 0xC(r8)
                  stwio r13,0(r9)
                                   #now check again if key is pressed 
check3:         ldwio r11, 0xC(r8)                #does the exact same thing as check 1
                 andi  r11,r11,0x1                 
                 bne        r11, r0, key_pressed1
                 ldwio r11, 0xC(r8)                
                 andi  r11,r11,0x2                 
                 bne        r11, r0, key_pressed2
                 ldwio r11, 0xC(r8)                
                 andi  r11,r11,0x14         
                 bne        r11, r0, key_pressed3
                 ldwio r11, 0xC(r8)                
                 andi  r11,r11,0x18         
                 bne        r11, r0, key_pressed4
                 br   check3
                                                        
stopcount4:
                  movi  r12, 0x8                # turn off edge capture bit
                  stwio r12, 0xC(r8)
                  stwio r13,0(r9)
                 #now check again if key is pressed 
check4:         ldwio r11, 0xC(r8)                #does the exact same thing as check 1
                 andi  r11,r11,0x1                 
                 bne        r11, r0, key_pressed1
                 ldwio r11, 0xC(r8)                
                 andi  r11,r11,0x2                 
                 bne        r11, r0, key_pressed2
                 ldwio r11, 0xC(r8)                
                 andi  r11,r11,0x14         
                 bne        r11, r0, key_pressed3
                 ldwio r11, 0xC(r8)                
                 andi  r11,r11,0x18         
                 bne        r11, r0, key_pressed4
                 br   check4
                 
                  
key_pressed1: 
    #write 1 back into the edge capture reg and start counting again 
        movi  r12, 0x1                # turn off edge capture bit
    stwio r12, 0xC(r8)
        br   DO_DELAY #since key is pressed we are gonna start counting again 
        
key_pressed2:
movi  r12, 0x2        # turn off edge capture bit
    stwio r12, 0xC(r8)
        br   DO_DELAY #since key is pressed we are gonna start counting again 
        
   
   
 key_pressed3:
movi  r12, 0x4        # turn off edge capture bit
    stwio r12, 0xC(r8)
        br   DO_DELAY #since key is pressed we are gonna start counting again 
        
   
 key_pressed4:
movi  r12, 0x8        # turn off edge capture bit
    stwio r12, 0xC(r8)
        br   DO_DELAY #since key is pressed we are gonna start counting again