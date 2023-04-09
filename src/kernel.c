void main() {
    // write some arbitrary data into video memory
    char* video_memory = (char*) 0xb8000;
    *video_memory = 'X';
    return;
}