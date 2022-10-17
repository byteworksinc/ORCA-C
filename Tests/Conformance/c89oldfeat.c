/*
 * Test old features from C89/C90 that have been removed or deprecated in C99+.
 */

int printf(const char *, ...);

#define M+4             /* no whitespace after macro name */

main ()                 /* implicit int, no prototypes */
{
        auto i,j;       /* implicit int */
        
        j = M;
        i = (const) j;  /* implicit int */
        i = (volatile) j;
        
        if (f(i) == 8)  /* calling undeclared function */
        {
                printf ("Passed Conformance Test c89oldfeat\n");
                return 0;
        };
        
        printf ("Failed Conformance Test c89oldfeat\n");
        return;         /* return no value from a function returning int */
}

f(x)                    /* implicit int, no prototypes */
                        /* implicit int parameter x */
{
        return x * 2;
}
