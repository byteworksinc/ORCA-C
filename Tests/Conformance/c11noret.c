/*
 * Test _Noreturn function specifier (C11).
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>

noreturn int f2(void) {
        printf ("Passed Conformance Test c11noret\n");
        exit(0);
}

_Noreturn void f1(void) {
        f2();
}

int main(void) {
        f1();
        printf ("Failed Conformance Test c11noret\n");
}
