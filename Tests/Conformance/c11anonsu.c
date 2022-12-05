/*
 * Test anonymous structures and unions (C11).
 */

#include <stdio.h>
#include <stddef.h>

struct S {
        int a;
        union {
                volatile struct {
                        long b;
                        char c;
                };
                double d;
        };
} s1 = {1,2,3};

struct T {
        int a;
        union {
                volatile struct {
                        long b;
                        char c;
                } s;
                double d;
        } u;
};

int main(void) {
        struct S *s1p = &s1;

        if (s1.a != 1)
                goto Fail;
        if (s1.b != 2)
                goto Fail;
        if (s1.c != 3)
                goto Fail;
        
        s1.d = 123.5;
        if (s1p->d != 123.5)
                goto Fail;
        
        struct S s2 = {4,5,6};
        struct S *s2p = &s2;

        if (s2.a != 4)
                goto Fail;
        if (s2.b != 5)
                goto Fail;
        if (s2.c != 6)
                goto Fail;
        
        s2.d = 123.5;
        if (s2p->d != 123.5)
                goto Fail;

        struct S s3 = {.b = 10, 20, .a=30};

        if (s3.a != 30)
                goto Fail;
        if (s3.b != 10)
                goto Fail;
        if (s3.c != 20)
                goto Fail;

        struct S s4 = {.a=30, 10, 20.5, .d = 123.5};

        if (s4.a != 30)
                goto Fail;
        if (s4.d != 123.5)
                goto Fail;

        if (sizeof(struct S) != sizeof(struct T))
                goto Fail;
        
        if (offsetof(struct S, a) != offsetof(struct T, a))
                goto Fail;
        if (offsetof(struct S, b) != offsetof(struct T, u.s.b))
                goto Fail;
        if (offsetof(struct S, c) != offsetof(struct T, u.s.c))
                goto Fail;
        if (offsetof(struct S, d) != offsetof(struct T, u.d))
                goto Fail;

        printf ("Passed Conformance Test c11anonsu\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c11anonsu\n");
}
