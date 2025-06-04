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

        printf ("Passed Conformance Test c99misc\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99misc\n");
}
