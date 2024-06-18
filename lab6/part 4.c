#include <stdio.h>




#define AUDIO_BASE 0xFF203040




#define D 0.6
#define N 3200




// structure for accessing audio registers
struct audio_t {
    volatile unsigned int control;
    volatile unsigned char rarc;
    volatile unsigned char ralc;
    volatile unsigned char wsrc;
    volatile unsigned char wslc;
    volatile unsigned int ldata;
    volatile unsigned int rdata;
};
// Pointer to the audio structure
    struct audio_t *const audiop = ((struct audio_t *)AUDIO_BASE);




int main(void) {
    audiop->control = 12; //clear CW & CR




   audiop->control = 0; // resume








    int left, right;
    int left_buffer[N] = {0};
    int right_buffer[N] = {0};




    int i = 0;
   
    while (1) {
     
       
        // Check if RARC has least one input
        if ( audiop->rarc > 0) {
            // Load both input microphone channels
            left = audiop->ldata;
            right = audiop->rdata;




           
            int left_eco = left_buffer[i]; // Get echo sample from left buffer
            int right_eco = right_buffer[i]; // Get echo sample from right buffer




            // Calculate echo effect for left channel
            int output_left = left + (int)(D * left_eco);




            // Calculate echo effect for right channel
            int output_right = right + (int)(D * right_eco);




            //update buffers
            left_buffer[i] = output_left ;
            right_buffer[i] = output_right ;




            i = (i + 1) % N; //next one
           
            // output data if there is space in the output FIFOs
          if (audiop->wsrc) {
             // Load both input microphone channels
            audiop->ldata = output_left;
            audiop->rdata = output_right;




           
        }
        }
    }
    return 0;
}
