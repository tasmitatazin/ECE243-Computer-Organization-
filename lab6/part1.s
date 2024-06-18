int main() 
{
  volatile int *LEDR_ptr = 0xFF200000;  // address of LEDs
  volatile int *SW_ptr = 0xFF200040;    // address of SWITCHES
  volatile int *KEY_BASE = 0xff200050;  // key address
  volatile int *edge_capture = 0xff20005C;
  int value;
  int LEDON = 0xffff;
  int LEDOFF = 0;
  /*this code reads from switches to leds
  while (1){
      value = *SW_ptr;
      *LEDR_ptr = value;
  }
  */
  // if key 0 is pressed all LED's should be on
  // if key 1 is pressed all of them should be turned off


  void TurnOnLed()
  {
    *(LEDR_ptr) = LEDON;
    // set edge capture back to 0 when key is no longer pressed
    *(edge_capture) = 0x1;
  }
  void TurnOffLed()
  {


    *(LEDR_ptr) = LEDOFF;
    //set edge capture back to 0 
    *(edge_capture) = 0x2;
  }


  while (1) {
    // load edge capture register
    value = *(edge_capture);
    // check if key 0 is pressed
    int check1;
    check1 = value & 0x1;
    // if key0 is pressed


    // turn on all LED's
    // keep on checking through polling
    if (check1) {
      //call fucntion to turn on LED and also turn on edge capture 
      TurnOnLed();
    }
    
    // check if key 1 is pressed
    int check2;
    check2 = value & 0x2;
    if (check2) {
    //call function to turn off led
    TurnOffLed();
    }
  }
  return 0; 


  
}