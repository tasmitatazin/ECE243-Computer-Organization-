#include "stdbool.h"
int pixel_buffer_start; // global variable








void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;


        one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);


        *one_pixel_address = line_color;
}


void clear_screen()
{
        int y, x;


        for (x = 0; x < 320; x++)
                for (y = 0; y < 240; y++)
                        plot_pixel (x, y, 0);
}


void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}


void draw_line(int x0, int y0, int x1, int y1, short int color) {
    // Check if the line is steep
    bool is_steep = abs(y1 - y0) > abs(x1 - x0);
    if (is_steep) {
        // If the line is steep, swap x and y coordinates
        swap(&x0, &y0);
        swap(&x1, &y1);
    }
    if (x0 > x1) {
        // If the starting x-coordinate is greater than the ending x-coordinate, swap them
        swap(&x0, &x1);
        swap(&y0, &y1);
    }


    // Calculate differences and error
    int deltax = x1 - x0;
    int deltay = abs(y1 - y0);
    int error = -(deltax / 2);
    int y = y0;
    int y_step = (y0 < y1) ? 1 : -1;


    // Loop over the range from x0 to x1
    for (int x = x0; x <= x1; x++) {
        if (is_steep) {
            // If the line is steep, plot pixel with swapped coordinates
            plot_pixel(y, x, color);
        } else {
            // If the line is not steep, plot pixel with normal coordinates
            plot_pixel(x, y, color);
        }
        error += deltay;
        if (error > 0) {
            y += y_step;
            error -= deltax;
        }
    }
}






int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;


    clear_screen();
    draw_line(0, 0, 150, 150, 0x001F);   // this line is blue
    draw_line(150, 150, 319, 0, 0x07E0); // this line is green
    draw_line(0, 239, 319, 239, 0xF800); // this line is red
    draw_line(319, 0, 0, 239, 0xF81F);   // this line is a pink color
}


// code not shown for clear_screen() and draw_line() subroutines