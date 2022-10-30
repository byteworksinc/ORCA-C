/*
 * Test inline function specifier (C99).
 *
 * This only tests "static inline" and "extern inline",
 * which are the only forms currently supported by ORCA/C.
 */

#include <stdio.h>

static inline int f(void) {
        return 1;
}

inline int extern g(void) {
        return 2;
}

int main(void) {
        int (*p)(void) = f;
        int (*q)(void) = g;

        if (f() + g() != 3)
                goto Fail;

        if (p() + q() != 3)
                goto Fail;
        
        printf ("Passed Conformance Test c99inline\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99inline\n");
}
