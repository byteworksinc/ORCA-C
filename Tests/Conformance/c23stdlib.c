/*
 * Test support for C23 <stdlib.h> features.
 */

#include <stdio.h>
#include <stdlib.h>

#define assert_type(e,t) (void)_Generic((e), t:0)

int cmp(const void *ap, const void *bp) {
        int a = *(const int *)ap;
        int b = *(const int *)bp;
        
        return a < b ? -1 : a > b;
}

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

#if __STDC_VERSION__ >= 202311L
        /* test bsearch generic function */
        static int a[] = {1,2,3,4,5,6};
        if (bsearch(&(int){3}, a, 6, sizeof(int), cmp) != a+2)
                goto Fail;
        if (bsearch(&(int){3}, (const int *)a, 6, sizeof(int), cmp) != a+2)
                goto Fail;

        assert_type(bsearch(&(int){3}, a, 6, sizeof(int), cmp), void *);
        assert_type(bsearch(&(int){3}, (const int *)a, 6, sizeof(int), cmp), const void *);
        assert_type(bsearch(&(int){3}, (void *)a, 6, sizeof(int), cmp), void *);
        assert_type(bsearch(&(int){3}, (const void *)a, 6, sizeof(int), cmp), const void *);

        assert_type((bsearch)(&(int){3}, (const int *)a, 6, sizeof(int), cmp), void *);
        assert_type((bsearch)(&(int){3}, (const void *)a, 6, sizeof(int), cmp), void *);

        assert_type(bsearch(&(int){3}, 0, 6, sizeof(int), cmp), void *);
        assert_type(bsearch(&(int){3}, (void*)0, 6, sizeof(int), cmp), void *);
#endif

        printf ("Passed Conformance Test c23stdlib\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23stdlib\n");
}
