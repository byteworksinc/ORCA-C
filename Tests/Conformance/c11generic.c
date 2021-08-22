/*
 * Test use of generic selection expressions (C11).
 */

#include <stdio.h>

#define g(x) _Generic((x),      \
        int: (x)+1,             \
        long: (x)+2,            \
        double: (x)+3,          \
        long double: (x)+4,     \
        unsigned char *: 100,   \
        int *: 101,             \
        default: 200            \
        )

int main(void) {
        int i;

        if (g(12345) != 12346)
                goto Fail;

        if (g(1000000L) != 1000002)
                goto Fail;

        if (g(123.0) != 126.0)
                goto Fail;

        if (g(123.0L) != 127.0L)
                goto Fail;

        if (g((unsigned char*)&i) != 100)
                goto Fail;

        if (g(&i) != 101)
                goto Fail;

        if (g(123u) != 200)
                goto Fail;

        printf ("Passed Conformance Test c11generic\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c11generic\n");
}
