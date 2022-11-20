/*
 * Test inline function specifier (C99).
 */

#include <stdio.h>

static inline int f(void) {
        return 1;
}

inline int extern g(void) {
        return 2;
}

inline int h(int i) {
        return i+5;
}

int main(void) {
        int (*p)(void) = f;
        int (*q)(void) = g;
        int (*r)(int) = h;

        if (f() + g() != 3)
                goto Fail;

        if (p() + q() != 3)
                goto Fail;
        
        if (h(2) != 7)
                goto Fail;
        if (r(23) != 28)
                goto Fail;
        
        printf ("Passed Conformance Test c99inline\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99inline\n");
}

extern inline int h(int i);
