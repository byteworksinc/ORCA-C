/*
 * Test C23 features in <stdarg.h> and varargs functions.
 */

#include <stdarg.h>
#include <stdio.h>

// varargs function with no fixed parameters
unsigned long long f(...) {
        va_list ap;
        unsigned long long val = 0;
        int x;

        // va_start with only one argument
        va_start(ap);
        
        do {
                x = va_arg(ap, int);
                val = val * 10 + x;
        } while (x != 0);
        
        va_end(ap);
        
        return val;
}

int main(void) {
        unsigned long long x;
        
        x = f(1,2,3,4,5,0);
        if (x != 123450)
                goto Fail;

        x = ((unsigned long long (*)(...))f)(4,5,6,7,8,0);
        if (x != 456780)
                goto Fail;

        printf ("Passed Conformance Test c23stdarg\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23stdarg\n");
}
