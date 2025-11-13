/*
 * Test support for C23 <string.h> features.
 */

#include <stdio.h>
#include <string.h>
#include <stddef.h>

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

        /* test memccpy */
        char buf[11] = "1234567890x";
        char hello[] = "HelloWorld";

        if (memccpy(buf, hello, 'x', 0) != NULL)
                goto Fail;
        if (memcmp(buf, "1234567890x", 11) != 0)
                goto Fail;

        if (memccpy(buf, hello, 'o', 10) != buf + 5)
                goto Fail;
        if (memcmp(buf, "Hello67890x", 11) != 0)
                goto Fail;

        if (memccpy(buf, hello, 'Q', 10) != NULL)
                goto Fail;
        if (memcmp(buf, "HelloWorldx", 11) != 0)
                goto Fail;

        printf ("Passed Conformance Test c23string\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23string\n");
}
