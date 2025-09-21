/*
 * Test support for C23 <stdlib.h> features.
 */

#include <stdio.h>
#include <stdlib.h>

int count = 0;

void once_func(void) {
        count++;
}

int main(void) {
        /* test call_once */
        once_flag flg = ONCE_FLAG_INIT;
        call_once(&flg, once_func);
        if (count != 1)
                goto Fail;
        call_once(&flg, once_func);
        call_once(&flg, once_func);
        call_once(&flg, once_func);
        if (count != 1)
                goto Fail;

        printf ("Passed Conformance Test c23stdlib\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23stdlib\n");
}
