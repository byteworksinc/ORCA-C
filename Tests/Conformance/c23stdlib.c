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

        /* check that free_sized and free_aligned_sized can be called */
        void *p = malloc(123);
        if (!p)
                goto Fail;
        free_sized(p, 123);

        p = aligned_alloc(_Alignof(long), 1234);
        if (!p)
                goto Fail;
        free_aligned_sized(p, _Alignof(long), 1234);

        printf ("Passed Conformance Test c23stdlib\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23stdlib\n");
}
