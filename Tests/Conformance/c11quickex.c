/*
 * Test quick_exit and at_quick_exit (C11).
 */

#include <stdio.h>
#include <stdlib.h>

void f1(void) {
        printf ("Passed Conformance Test c11quickex\n");
        fflush(stdout);
}

void f2(void) {
        printf ("Failed Conformance Test c11quickex\n");
}

int main(void) {
        atexit(f2);
        at_quick_exit(f1);
        quick_exit(0);
}
