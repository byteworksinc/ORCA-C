/*
 * Test of _Bool type and <stdbool.h> header (C99).
 */

#include <stdio.h>
#include <stdbool.h>

int main(void) {
        _Bool a = true;
        bool b = false;

        if (true != 1 || false != 0)
                goto Fail;

        if (!a || b)
                goto Fail;
        
        if (!++a)
                goto Fail;
        if (!a)
                goto Fail;
        
        if (--a)
                goto Fail;
        if (--a != true)
                goto Fail;
        
        b = 0x80000000;
        if (!b)
                goto Fail;
        
        b = 2 + 4 == 5;
        if (b)
                goto Fail;
        
        a = 0.0001;
        b = 0.0;
        
        if (b || !a)
                goto Fail;
        
        a = (void*)0;
        b = &a;
        
        if (a || !b)
                goto Fail;
        
        struct {
                bool a : 1;
                _Bool b : 1;
        } s;
        
        s.a = true;
        s.b = false;
        
        if (!s.a || s.b)
                goto Fail;

        if (!++s.a)
                goto Fail;
        if (!s.a)
                goto Fail;
        
        if (--s.a)
                goto Fail;
        if (--s.a != true)
                goto Fail;

        s.b = 0x80000000;
        if (!s.b)
                goto Fail;

        s.b = 2 + 4 == 5;
        if (s.b)
                goto Fail;

        s.a = 0.0001;
        s.b = 0.0;
        
        if (s.b || !s.a)
                goto Fail;
        
        s.a = (void*)0;
        s.b = &a;
        
        if (s.a || !s.b)
                goto Fail;
        
        _Bool b1 = 123;
        _Bool b2 = -123.5;
        _Bool b3 = 0.0;
        static _Bool b4 = 0x100000000;
        static _Bool b5 = 0.0001;
        static _Bool b6 = -0.0;
        static _Bool b7 = &main;
        
        if (b1 != 1 || b2 != 1 || b3 != 0 || b4 != 1 || b5 != 1 || b6 != 0 || b7 != 1)
                goto Fail;

        printf ("Passed Conformance Test c99bool\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99bool\n");
}
