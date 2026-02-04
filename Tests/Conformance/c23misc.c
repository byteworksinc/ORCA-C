/*
 * Test miscellaneous C23 features.
 */

#include <stddef.h>
#include <stdio.h>
#include <assert.h>

#pragma STDC FENV_ROUND FE_DYNAMIC

#if __has_include(<stdio.h>) != 1 || __has_include(<nonexistent_file.h>) != 0
#error "__has_include error"
#endif

#if __has_include("5:Linker") || !defined(__has_include)
#error "__has_include error"
#endif

int main(void) {
        // labels not preceding a statement
        {
                foo: int i;
                bar:
        }
        
        // u8'x' character constants
        unsigned char x = u8'x';
        if (x != 0x78)
                goto Fail;
        x = u8'\u007f';
        if (x != 0x7f)
                goto Fail;
        x = u8'\xff';
        if (x != 0xff)
                goto Fail;
        x = u8'\n';
        if (x != 0x0a)
                goto Fail;
        if (!_Generic(u8'?', unsigned char: 1))
                goto Fail;

        // #elifdef and #elifndef
#define m1
        int y = 0;
#if 0
        y = 1;
#elifdef m1
        y = 2;
#elifndef m2
        y = 3;
#else
        y = 4;
#endif
        if (y != 2)
                goto Fail;

        y = 0;
#if 0
        y = 1;
#elifdef m2
        y = 2;
#else
        y = 3;
#endif
        if (y != 3)
                goto Fail;

        y = 0;
#if 0
        y = 1;
#elifndef m1
        y = 2;
#else
        y = 3;
#endif
        if (y != 3)
                goto Fail;

        y = 0;
#if 0
        y = 1;
#elifndef m2
        y = 2;
#endif
        if (y != 2)
                goto Fail;

        // comma in assert argument
        assert((int[]){y, 0}[0]);

        // empty initialization
        int z = {};
        if (z != 0)
                goto Fail;

        float f = {};
        if (f != 0.0)
                goto Fail;

        void *p = {};
        if (p != NULL)
                goto Fail;

        int a[2] = {};
        if (a[0] != 0 || a[1] != 0)
                goto Fail;

        union {int a:2;} u = {};
        if (u.a != 0 || *(unsigned char *)&u != 0)
                goto Fail;

        struct {char a; int b:2;} s = {};
        if (s.a != 0 || s.b != 0)
                goto Fail;
        for (size_t i = 0; i < sizeof(s); i++)
                if (((unsigned char *)&s)[i] != 0)
                        goto Fail;

        printf ("Passed Conformance Test c23misc\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23misc\n");
}
