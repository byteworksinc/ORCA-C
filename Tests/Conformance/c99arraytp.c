/*
 * Test of qualifiers and/or 'static' in array parameter types (C99).
 */

#include <stdio.h>

int f(long x[const static 20], short y[static volatile 1], int z[const]) {
        return x[0] + y[0] + z[0];
}

int main(void) {
        long X[20] = {5};
        short Y[15] = {60};
        int Z = 700;
        
        if (f(X,Y,&Z) != 765)
                goto Fail;

        printf ("Passed Conformance Test c99arraytp\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99arraytp\n");
}
