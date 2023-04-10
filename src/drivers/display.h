#define VIDEO_ADDRESS 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80
#define WHITE_ON_BLACK 0x0f

// Screen i/o ports
#define VGA_CTRL_REGISTER 0x3d4
#define VGA_DATA_REGISTER 0x3d5
#define VGA_OFFSET_LOW 0x0f
#define VGA_OFFSET_HIGH 0x0e

// Public kernel API 
void set_cursor(int offset);
int get_cursor();
int get_offset(int col, int row);
int get_row_from_offset(int offset);
int move_offset_to_new_line(int offset);
void set_char_at_video_memory(char character, int offset);
int scroll_ln(int offset);
void print_string(char *string);
void print_nl();
void clear_screen();