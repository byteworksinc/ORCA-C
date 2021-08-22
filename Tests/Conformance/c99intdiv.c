/*
 * Test that integer division involving negative numbers follows C99 rules.
 */

#include <stdio.h>

int main(void) {
        if ((-7) / 3 != -2)
                goto Fail;

        if ((-7) % 3 != -1)
                goto Fail;

        if (7 / -3 != -2)
                goto Fail;

        if (7 % -3 != 1)
                goto Fail;

        printf ("Passed Conformance Test c99intdiv\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99intdiv\n");
}
