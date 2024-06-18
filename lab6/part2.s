#include <stdio.h>


#define AUDIO_BASE 0xFF203040


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
        // Check if RARC has least one input
        if ( audiop->rarc > 0) {
            // Load both input microphone channels
            left = audiop->ldata;
            right = audiop->rdata;






    int left, right;
   
   
    while (1) {
     
                  
            // output data if there is space in the output FIFOs
          if (audiop->wsrc) {
            // Store both of those samples to output channels
            audiop->ldata = left;
            audiop->rdata = right;
        }
        }
    }
    return 0;
}