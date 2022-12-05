/*
 * Test of designated initializers (C99).
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifndef __ORCAC__
typedef long long comp;
#endif

struct S1 {
        int i;
        union {
                long x;
                char y;
        } u;
        short a[3];
} s1 =  {8, .a[0] = 9, .u.y = 'F', .i = 50, .a = {[1]=1,2}, .a[1] = 10};

struct S2 {
        char c;
        unsigned char uc;
        signed char sc;
        short s;
        unsigned short us;
        int i;
        unsigned int ui;
        long l;
        unsigned long ul;
        long long ll;
        unsigned long long ull;
        _Bool b;
        float f;
        double d;
        long double ld;
        comp cp;
        void *p;
} s2 =  {.p = &s2, .i = 123.4, .ui = 70, -123456, 123456, .c = 'd', 'e', 'f',
        .us = 78, .s = 40.1, .ll = 1234567890, 0x800000001, 123, 123.5,
        .cp = 9876543210, .d = -456.5, -789.5,
        };

struct S3 {
        float f;
        double d;
        long double ld;
} s3 = {-123456LL, 3000000000U, 12345678900ULL};

char s4[] = {{123}, [3] = {'x'}};

struct S5 {
        int :16;
        signed int a:4;
        signed int b:6;
        signed int c:6;
        int :0;
        unsigned d:9;
        int :12;
        unsigned e:4;
        unsigned f:16;
        long g;
        int :15;
} s5 = {-4, -5, 3, .g = 123456789, .d = 455, 8, 42345};

char *s6[4] = {s4, s4+1, [0]=0, [1]=s4+2, &s4[3], s4+4};

union U9 {
        union U9 *p;
        char s[6];
} s9 = {&s9, .s = {"abcde"}, .s[1] = 'x'};

union U9 s10 = {&s9, .s = {"abcde"}, .s[1] = 'x', .p = &s10};

union U9 s11 = {&s9, .s[1] = 'x'};

struct S13 {
        struct S13a {
                struct S13b {
                        struct S13c {
                                int a;
                                int b;
                        } z;
                } y;
        } x;
} s13 = {13, .x.y.z = {.b = 14}};

int f1(int i) {return i * 2 + 1;}

int main(void) {
        struct S1 a1 = 
                {8, .a[0] = 9, .u.y = 'F', .i = 50, .a = {[1]=1,2}, .a[1] = 10};
        
        struct S2 a2 =
                {.p = &s2, .i = 123.4, .ui = 70, -123456, 123456, .c = 'd', 'e', 'f',
                .us = 78, .s = 40.1, .ll = 1234567890, 0x800000001, 123, 123.5,
                .cp = 9876543210, .d = -456.5, -789.5,
                };
        
        struct S3 a3 = {-123456LL, 3000000000U, 12345678900ULL};

        char a4[] = {{123}, [3] = {'x'}};
        
        struct S5 a5 = {-4, -5, 3, .g = 123456789, .d = 455, 8, 42345};
        
        char *a6[4] = {s4, s4+1, [0]=0, [1]=s4+2, &s4[3], s4+4};

        char a7[] = {"foo"[0], [1] = "foo"[2], "foo"[3]};
        
        char a8[] = {"foo" != 0, [1] = "foo" == 0};
        
        union U9 a9 = {&s9, .s = {"abcde"}, .s[1] = 'x'};

        union U9 a10 = {&s9, .s = {"abcde"}, .s[1] = 'x', .p = &s10};

        union U9 a11 = {&s9, .s[1] = 'x'};

        struct S3 a12 = {.ld = f1(1)-8, .f = f1(2)*7, f1(3)+10};

        struct S13 a13 = {s13.x.y};

        if (s1.i!=50 || s1.u.y!='F' || s1.a[0]!=0 || s1.a[1]!=10 || s1.a[2]!=2)
                goto Fail;

        if (a1.i!=50 || a1.u.y!='F' || a1.a[0]!=0 || a1.a[1]!=10 || a1.a[2]!=2)
                goto Fail;

        if (s2.c != 'd' || s2.uc != 'e' || s2.sc != 'f' || s2.s != 40
                || s2.us != 78 || s2.i != 123 || s2.ui != 70 || s2.l != -123456
                || s2.ul != 123456 || s2.ll != 1234567890 
                || s2.ull != 0x800000001 || s2.b != 1 || s2.f != 123.5
                || s2.d != -456.5 || s2.ld != -789.5 || s2.cp != 9876543210
                || s2.p != &s2)
                goto Fail;

        if (a2.c != 'd' || a2.uc != 'e' || a2.sc != 'f' || a2.s != 40
                || a2.us != 78 || a2.i != 123 || a2.ui != 70 || a2.l != -123456
                || a2.ul != 123456 || a2.ll != 1234567890 
                || a2.ull != 0x800000001 || a2.b != 1 || a2.f != 123.5
                || a2.d != -456.5 || a2.ld != -789.5 || a2.cp != 9876543210
                || a2.p != &s2)
                goto Fail;

        if (s3.f != -123456.0 || s3.d != 3000000000.0 || s3.ld != 12345678900.0)
                goto Fail;

        if (a3.f != -123456.0 || a3.d != 3000000000.0 || a3.ld != 12345678900.0)
                goto Fail;

        if (sizeof(s4) != 4 || s4[0] != 123 || s4[1] != 0 || s4[2] != 0 
                || s4[3] != 'x')
                goto Fail;

        if (sizeof(a4) != 4 || a4[0] != 123 || a4[1] != 0 || a4[2] != 0 
                || a4[3] != 'x')
                goto Fail;

        if (s5.a != -4 || s5.b != -5 || s5.c != 3 || s5.d != 455 || s5.e != 8
                || s5.f != 42345 || s5.g != 123456789)
                goto Fail;

        if (a5.a != -4 || a5.b != -5 || a5.c != 3 || a5.d != 455 || a5.e != 8
                || a5.f != 42345 || a5.g != 123456789)
                goto Fail;

        if (s6[0] != 0 || s6[1] != &s4[2] || s6[2] != &s4[3] || s6[3] != s4+4)
                goto Fail;

        if (a6[0] != 0 || a6[1] != &s4[2] || a6[2] != &s4[3] || a6[3] != s4+4)
                goto Fail;

        if (sizeof(a7) != 3 || a7[0] != 'f' || a7[1] != 'o' || a7[2] != 0)
                goto Fail;

        if (sizeof(a8) != 2 || a8[0] != 1 || a8[1] != 0)
                goto Fail;

        if (strcmp(s9.s, "axcde") != 0)
                goto Fail;

        if (strcmp(a9.s, "axcde") != 0)
                goto Fail;

        if (s10.p != &s10)
                goto Fail;

        if (a10.p != &s10)
                goto Fail;

        if (s11.s[1] != 'x')
                goto Fail;

        if (a11.s[1] != 'x')
                goto Fail;

        if (a12.f != 35 || a12.d != 17 || a12.ld != -5)
                goto Fail;

        if (a13.x.y.z.a != 0 || a13.x.y.z.b != 14)
                goto Fail;

        printf ("Passed Conformance Test c99desinit\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99desinit\n");
}
