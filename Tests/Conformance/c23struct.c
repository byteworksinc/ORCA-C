/*
 * Test C23 struct/union compatibility rules.
 */

#include <stdio.h>

#if __STDC_VERSION__ < 202311L
#error This is not expected to work in pre-C23 language versions.
#else

struct S1 {
        int a,b,c;
} s1 = {1,2,3};

struct S2 {
        int x;
        int a[];
} s2;

struct S3 {
        int x;
        struct {
                long y;
                float z;
        };
} s3;

struct S4 {
        int x:2;
        int :0;
        int y:2;
} s4;

struct S5 {
        struct S1 s1;
} s5;

union U1 {
        int x:7;
        long y;
} u1;

#define expect_incompatible(t1,t2) \
        _Static_assert(_Generic((t1 *)0, t2 *: 0, default: 1))

int main(void) {
        struct S1 {
                int a;
                int b,c;
        } s1b, *sp1;

        struct S3 {
                int x;
                struct {
                        long y;
                        float z;
                };
        } s3b, *sp3;

        struct S5 {
                struct S1 s1;
        } s5b, *sp5;

        union U1 {
                int x:7;
                long y;
        } u1b, *up1;

        s1b = s1;
        sp1 = &s1;
        
        if (s1b.a != 1 || s1b.b != 2 || s1b.c != 3)
                goto Fail;
        if (sp1->a != 1 || sp1->b != 2 || sp1->c != 3)
                goto Fail;

        s3b = s3;
        sp3 = &s3;

        s5b = s5;
        sp5 = &s5;

        u1b = u1;
        up1 = &u1;

        {
                struct S1 {
                        int a;
                        int b;
                };
                expect_incompatible(typeof(s1), struct S1);
        }
        {
                struct S1 {
                        int a;
                        int b,c,d;
                };
                expect_incompatible(typeof(s1), struct S1);
        }
        {
                struct S1 {
                        int a;
                        int b,c:16;
                };
                expect_incompatible(typeof(s1), struct S1);
        }
        {
                struct S1 {
                        short a;
                        int b,c;
                };
                expect_incompatible(typeof(s1), struct S1);
        }
        {
                struct S1x {
                        int a,b;
                        int c;
                };
                expect_incompatible(typeof(s1), struct S1x);
        }
        {
                struct S1 {
                        int a,b;
                        const int c;
                };
                expect_incompatible(typeof(s1), struct S1);
        }
        {
                union S1 {
                        int a,b;
                        int c;
                };
                expect_incompatible(typeof(s1), union S1);
        }
        {
                struct S1 {
                        int a,b,c;
                        int :1;
                };
                expect_incompatible(typeof(s1), struct S1);
        }
        {
                struct S2 {
                        int x;
                        int a[1];
                };
                /* See C23 issue 1000 */
                expect_incompatible(typeof(s2), struct S2);
        }
        {
                struct S3 {
                        int x;
                        struct {
                                long y;
                        };
                        float z;
                };
                expect_incompatible(typeof(s3), struct S3);
        }
        {
                struct S3 {
                        int x;
                        struct {
                                long y;
                        };
                        struct {
                                float z;
                        };
                };
                expect_incompatible(typeof(s3), struct S3);
        }
        {
                struct S3 {
                        int x;
                        struct {
                                long y;
                                float z;
                        } s;
                };
                expect_incompatible(typeof(s3), struct S3);
        }
        {
                struct S4 {
                        int x:2;
                        int y:2;
                };
                expect_incompatible(typeof(s4), struct S4);
        }
        {
                struct S4 {
                        int x:2;
                        int :1;
                        int y:2;
                };
                expect_incompatible(typeof(s4), struct S4);
        }
        {
                union U1 {
                        int x:8;
                        long y;
                };
                expect_incompatible(typeof(u1), union U1);
        }
        {
                union U1 {
                        long y;
                        int x:7;
                };
                expect_incompatible(typeof(u1), union U1);
        }

        printf ("Passed Conformance Test c23struct\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23struct\n");
}

#endif
