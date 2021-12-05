/*
 * Test hexadecimal floating-point constants (C99).
 */

#include <math.h>
#include <stdio.h>

int main(void) {
        double d;
        long double ld;
        
        /* Parts of this assume 80-bit long double format. */
        
        d = 0xF.8p-1;
        if (d != 7.75)
                goto Fail;
        
        d = 0XAB4fp2;
        if (d != 175420.0)
                goto Fail;
        
        d = 0X.23423p-1;
        if (d != (double)0.06886434555053710938)
                goto Fail;
        
        d = 0x4353.p+7;
        if (d != (double)2206080.0)
                goto Fail;

        ld = 0xabcdef0012345678ffffffffffffp123L;
        if (ld != 3.7054705751091077761e+70L)
                goto Fail;
        
        ld = 0xabcdef0012345678000000000000p123L;
        if (ld != 3.7054705751091077758e+70L)
                goto Fail;
        
        ld = 0x0.0000000000000000000000012345aP50L;
        if (ld != 1.61688425235478883124e-14L)
                goto Fail;
        
        ld = 0x1324124.abcd23p-3000L;
        if (ld != 1.63145601325652579262e-896L)
                goto Fail;
        
        ld = 0x0000000000.000000p1234567890123456789012345678901234567890L;
        if (ld != 0.0)
                goto Fail;
        
        ld = 0X1p17000L;
        if (ld != INFINITY)
                goto Fail;
        
        ld = 0x1.fffffffffffffffep16383L;
        if (ld != 1.18973149535723176502e+4932L)
                goto Fail;
        
        ld = 0x1.ffffffffffffffffp16383L;
        if (ld != INFINITY)
                goto Fail;
        
        ld = 0X1p-16400L;
        if (ld != 1.28254056667789211512e-4937L)
                goto Fail;
        if (ld == 0)
                goto Fail;
        
        ld = 0x3abd.232323p-16390L;
        if (ld != 1.97485962609712244075e-4930L)
                goto Fail;
        
        ld = 0x7.7p-17000L;
        if (ld != 0.0)
                goto Fail;
        
        printf ("Passed Conformance Test c99hexflt\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99hexflt\n");
}
