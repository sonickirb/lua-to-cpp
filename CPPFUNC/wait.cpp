const unsigned int microsecond = 1000000;

void wait(double seconds) {
    usleep(seconds * microsecond);
}