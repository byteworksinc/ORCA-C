/*
 * Test alignment functionality (C11/C17).
 */

#include <stdio.h>
#include <stdalign.h>
#include <stddef.h>
#include <stdlib.h>

int main(void) {
        char _Alignas(short) a;
        alignas(_Alignof(max_align_t)) char b;
        
        a = 'a';
        b = 'b';
        
        if (a != 'a' || b != 'b')
                goto Fail;

        if (!(alignof(char) <= _Alignof(int)))
                goto Fail;
        
        if (!(alignof(long double) <= _Alignof(max_align_t)))
                goto Fail;

        long *lp = aligned_alloc(alignof(long), sizeof(long)*2);
        if (lp == NULL)
                goto Fail;
        *(lp+1) = 123456789;
        if (lp[1] != 123456789)
                goto Fail;
        free(lp);
        
        // aligned_alloc with invalid alignment must return NULL (C17).
        lp = aligned_alloc(123, 123);
        if (lp)
                goto Fail;

        printf ("Passed Conformance Test c11align\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c11align\n");
}
