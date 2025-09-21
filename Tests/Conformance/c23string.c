/*
 * Test support for C23 <string.h> features.
 */

#include <stdio.h>
#include <string.h>

char buf[10];

int main(void) {
        int i;

        /* test memset_explicit */
        memset_explicit(buf, 'x', sizeof(buf));
        for (i = 0; i < sizeof(buf); i++) {
                if (buf[i] != 'x')
                        goto Fail;
        }
        memset_explicit(buf, 0x7f00, sizeof(buf));
        for (i = 0; i < sizeof(buf); i++) {
                if (buf[i] != 0)
                        goto Fail;
        }

        printf ("Passed Conformance Test c23string\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23string\n");
}
