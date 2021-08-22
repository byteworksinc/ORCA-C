/*
 * Test support for <iso646.h> (C95).
 */

#include <stdio.h>
#include <iso646.h>

int main(void) {
        unsigned int u = 0x000F;

        if (not ((0 or 1) and 1))
                goto Fail;

        u = compl u;
        u and_eq 0x056E;
        u or_eq 0x4000;
        u xor_eq 0x000C;
        
        if (u not_eq 0x456C)
                goto Fail;
        
        u = ((0x3000 bitand 0x1400) bitor 0x0020) xor 0x0320;
        
        if (u not_eq 0x1300)
                goto Fail;

        printf ("Passed Conformance Test c95iso646\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c95iso646\n");
}
