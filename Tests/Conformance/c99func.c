/*
 * Test __func__ (C99).
 */

#include <stdio.h>
#include <string.h>

int main(void) {
        const char *p = __func__;

        if (strcmp(__func__, "main") != 0)
                goto Fail;
        
        if (sizeof __func__ != 5)
                goto Fail;
        
        {
                if (p != __func__)
                        goto Fail;
        }

        printf ("Passed Conformance Test c99func\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99func\n");
}
