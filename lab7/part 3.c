#include <stdbool.h>
#include <stdlib.h>




volatile int pixel_buffer_start;  // global variable
short int Buffer1[240][512];      // 240 rows, 512 (320 + padding) columns
short int Buffer2[240][512];




short int box_size = 15;  // set box size




// set dimensions
int size_x = 320;
int size_y = 240;




// Define the box structure
typedef struct {
  int x, y;    // Position
  int dx, dy;  // Direction of movement
  short int color;
} Box;




short int LINES[10] = {
    0xFFFF,  // White
    0xF800,  // Red
    0x07E0,  // Green
    0x001F,  // Blue
    0xFFE0,  // Yellow
    0xF81F,  // Magenta
    0x07FF,  // Cyan
    0x7BEF,  // Light Grey
    0x7FFF,  // Light Blue
    0xF77B   // Pink
};




int colour[10] = {
    0xFFFF,  // White
    0xF800,  // Red
    0x07E0,  // Green
    0x001F,  // Blue
    0xFFE0,  // Yellow
    0xF81F,  // Magenta
    0x07FF,  // Cyan
    0x7BEF,  // Light Grey
    0x7FFF,  // Light Blue
    0xF77B   // Pink
};




Box boxes[8] = {};  // array of boxes of 8




// Function Definitions
void plot_pixel(int x, int y, short int line_color);
void wait_for_vsync();
void initialize_boxes();
void clear_screen();
void swap(int *a, int *b);
void draw_box(int x, int y, int length, int width, short int colourr);
void draw_line(int x0, int y0, int x1, int y1, short int color);
// void draw();




int main(void) {








    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;




    //int short col= 0xffff; 
    // initialize location and direction of rectangles
    initialize_boxes();




    /* set front pixel buffer to Buffer 1 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer1; // first store the address in the  back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer




    /* set back pixel buffer to Buffer 2 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer2;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer






  while (1) {
    /* Erase any boxes and lines that were drawn in the last iteration */
    clear_screen();
    // code for drawing the boxes and lines (not shown)
    for (int i = 0; i < 8; ++i) {
      draw_box(boxes[i].x, boxes[i].y, box_size, box_size, boxes[i].color);
      // code for updating the locations of boxes (not shown)
      if (i == 7) {
        draw_line(boxes[i].x, boxes[i].y, boxes[0].x, boxes[0].y, LINES[i]);
      } else {
        draw_line(boxes[i].x, boxes[i].y, boxes[i+1].x, boxes[i+1].y, LINES[i]);
      }
    }




    for (int i = 0; i < 8; ++i) {
      if (boxes[i].x == 319-box_size) {
        boxes[i].dx = -1;
      }
      if (boxes[i].y == 0) {
        boxes[i].dy = 1;
      }
      if (boxes[i].x == 0) {
        boxes[i].dx = 1;
      }
      if (boxes[i].y == 239-box_size) {
        boxes[i].dy = -1;
      };




      boxes[i].x = boxes[i].x + boxes[i].dx;
      boxes[i].y = boxes[i].y + boxes[i].dy;
    }




    wait_for_vsync();  // swap front and back buffers on VGA vertical sync
    pixel_buffer_start = *(pixel_ctrl_ptr + 1);  // new back buffer
  }
  return 0;
}




// code for subroutines (not shown)




void plot_pixel(int x, int y, short int line_color) {
  volatile short int *one_pixel_address;




  one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);




  *one_pixel_address = line_color;
}




void wait_for_vsync() {
  volatile int *pixel_ctrl_ptr = (int *)0xff203020;  // base address
  int status;
  *pixel_ctrl_ptr = 1;  // start the synchronization process
  // write 1 into front buffer address register
  status = *(pixel_ctrl_ptr + 3);  // read the status register
  while ((status & 0x01) != 0)     // polling loop waiting for S bit to go to 0
  {
    status = *(pixel_ctrl_ptr + 3);
  }  // loop/function exits when status bit goes to 0
}




void initialize_boxes() {
  for (int i = 0; i < 8; i++) {
    boxes[i].x = rand() % (size_x - box_size -
                           1);  // Random x position within screen bounds
    boxes[i].y = rand() % (size_y - box_size -
                           1);       // Random y position within screen bounds
    boxes[i].dx = (rand() % 3) - 1;  // Random dx direction (-1, 0, or 1)
    boxes[i].dy = (rand() % 3) - 1;  // Random dy direction (-1, 0, or 1)
    boxes[i].color = colour[rand() % 10];  // Random color from the color array




    // Ensure that dx and dy are not both zero (no movement)
    if (boxes[i].dx == 0 && boxes[i].dy == 0) {
      boxes[i].dx = 1;
    }
  }
}




void clear_screen() {
  int y, x;




  for (x = 0; x < 320; x++)
    for (y = 0; y < 240; y++) plot_pixel(x, y, 0);
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
    // If the starting x-coordinate is greater than the ending x-coordinate,
    // swap them
    swap(&x0, &x1);
    swap(&y0, &y1);
  }
        
        int to_center = box_size/2;
        x0 += to_center;
        y0 += to_center;


        x1 += to_center;
        y1 += to_center;


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


void draw_box(int x, int y, int length, int width, short int colourr) {
    int initial_x = x; // Save the initial x coordinate
    for (int i = 0; i < length; ++i) {
        x = initial_x; // Reset x to the initial value at the start of each row
        for (int j = 0; j < width; ++j) {
            plot_pixel(x, y, colourr);
            x =x+1; // Move right after plotting each pixel
        }
        y =y+1; // Move down after completing each row
    }
}