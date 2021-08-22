/*
 * Test macros with variable arguments and empty macro arguments (C99).
 */

#include <stdio.h>
#include <string.h>

#define a(x) (x + 5)

#define print(fmt, ...) sprintf(str, fmt, __VA_ARGS__)

char str[100];

int main(void) {
        if (a() != a(0))
                goto Fail;

        print("%i %s", 123, "hi");
        if (strcmp(str, "123 hi") != 0)
                goto Fail;

        print("%u %s %x", 123, "hi", 0xA8);
        if (strcmp(str, "123 hi a8") != 0)
                goto Fail;

        printf ("Passed Conformance Test c99macros\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99macros\n");
}

