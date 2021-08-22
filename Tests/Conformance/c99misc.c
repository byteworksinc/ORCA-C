/*
 * Test miscellaneous C99 features.
 */

#include <stdio.h>
#include <ctype.h>

/* __STDC_HOSTED__ predefined macro */
#if !defined(__STDC_HOSTED__) || __STDC_HOSTED__ != 1
#error "Not a hosted implementation of C99+"
#endif

/* Trailing comma in enums */
enum {A,B,C,};

/* static inline functions */
inline static int f(void) {
        return C;
}

/* restricted pointers and idempotent type qualifiers */
void g(char *restrict c1, char * const restrict const c2) {
        *c1 = *c2;
}

int main(void) {
        /* // comments */ char s[] = 
        // This is a comment
        "But this is not";
        
        if (sizeof s != 16)
                goto Fail;
        
        if (f() != 2)
                goto Fail;
        
        /* Mixed declarations and statements */
        char c = 'x';
        
        /* Declarations in for loops */
        for (int i = 0; i < 256; i++) {
                /* isblank() macro/function */
                if ((_Bool)isblank(i) != (i == ' ' || i == '\t'))
                        goto Fail;
                if ((_Bool)(isblank)(i) != (i == ' ' || i == '\t'))
                        goto Fail;
        }
        
        g(&c,s);
        if (c != 'B')
                goto Fail;
        
        printf ("Passed Conformance Test c99misc\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99misc\n");
}
