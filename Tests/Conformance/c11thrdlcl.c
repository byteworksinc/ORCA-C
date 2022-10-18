/*
 * Test _Thread_local (C11).
 */

#include <stdio.h>

extern _Thread_local int i;
char static _Thread_local c = 5;
_Thread_local struct {int x,y,z;} s = {3,6,8};

int main(void) {
        _Thread_local int extern j;
        static _Thread_local long d = 4567; 
        
        d = 123;
        i = 14;
        
        if (i+j+c+d+s.x+s.y+s.z != 171)
                goto Fail;

        printf ("Passed Conformance Test c11thrdlcl\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c11thrdlcl\n");
}

int _Thread_local i = 9999;
_Thread_local int j = 12;
