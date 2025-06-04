/*
 * Test miscellaneous C23 features.
 */

#include <stdio.h>

int main(void) {
        // labels not preceding a statement
        {
                foo: int i;
                bar:
        }
        
        // u8'x' character constants
        unsigned char x = u8'x';
        if (x != 0x78)
                goto Fail;
        x = u8'\u007f';
        if (x != 0x7f)
                goto Fail;
        x = u8'\xff';
        if (x != 0xff)
                goto Fail;
        x = u8'\n';
        if (x != 0x0a)
                goto Fail;
        if (!_Generic(u8'?', unsigned char: 1))
                goto Fail;

        // #elifdef and #elifndef
#define m1
        int y = 0;
#if 0
        y = 1;
#elifdef m1
        y = 2;
#elifndef m2
        y = 3;
#else
        y = 4;
#endif
        if (y != 2)
                goto Fail;

        y = 0;
#if 0
        y = 1;
#elifdef m2
        y = 2;
#else
        y = 3;
#endif
        if (y != 3)
                goto Fail;

        y = 0;
#if 0
        y = 1;
#elifndef m1
        y = 2;
#else
        y = 3;
#endif
        if (y != 3)
                goto Fail;

        y = 0;
#if 0
        y = 1;
#elifndef m2
        y = 2;
#endif
        if (y != 2)
                goto Fail;

        printf ("Passed Conformance Test c99misc\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99misc\n");
}
