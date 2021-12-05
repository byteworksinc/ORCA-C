/*
 * Test of compound literals (C99).
 *
 * This currently only tests compound literals outside of functions,
 * since that is the only place where ORCA/C currently supports them.
 */

#include <stdio.h>

int *p = (int[]){1,2,3};
int *q = &(int[100]){4,5,6}[1];
struct S *s = &(struct S {int i; double d; void *p;}){100,200.5,&p};

int main(void) {
        if (p[2] != 3)
                goto Fail;
        
        if (*q != 5)
                goto Fail;
        
        if (q[80] != 0)
                goto Fail;
        
        p[2] = s->i;
        if (p[2] != 100)
                goto Fail;

        printf ("Passed Conformance Test c99complit\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99complit\n");
}
