#include <stdio.h>
#include <math.h>
 
int main(void) {


struct audio_t {


      volatile unsigned int control;
      volatile unsigned char rarc;
      volatile unsigned char ralc;
      volatile unsigned char wsrc;
      volatile unsigned char wslc;
      volatile unsigned int ldata;
      volatile unsigned int rdata;


};




int findIndexOfSetBit(int num) {
    int index = 0;
   
    // Iterate through each bit position
    while (num > 0) {
        // Check if the least significant bit is set
        if (num & 1) {
            return index; // If set, return the index
        }
       
        // Move to the next bit
        num = num >> 1;
        index++;
    }
   
    // If no bits are set
    return 1;
}








struct audio_t *const audiop = ((struct audio_t *)0xff203040);








       int sample_size;








        volatile int *SW_ptr = (int*)0xFF200040;    // address of SWITCHES
        int Switches_value;
        int samples[80];
        int constant=(8000);
        //set the different frequencies for each switch
        int freq_values[10]={100, 200, 250, 320, 400, 500, 800, 1000, 1600, 2000};








        void squarewave(int frequency)
        { sample_size= constant/frequency;
            int high_values_no=sample_size/2;
            int j;
            for (j=0;j<high_values_no;j++)
                samples[j]=0xfffff;
            for (j = high_values_no;j<sample_size;j++)
                samples[j]=0;                      
        }








 while (1){
           
            Switches_value=*(SW_ptr);




            int freq= freq_values[findIndexOfSetBit(Switches_value)-1];
            squarewave(freq);


            audiop->control = 12; //clear CW & CR
           
            audiop->control = 0x8; // clear the output FIFOs








            audiop->control = 0x0; // resume input conversion






            int i = 0;
            while (i < sample_size){


               if(audiop->wsrc==0){
                   
                }
                    audiop->ldata = samples[i]<<16;




                  audiop->rdata = samples[i]>>16;
                  i+=1;


            }
         
 }
       
 }