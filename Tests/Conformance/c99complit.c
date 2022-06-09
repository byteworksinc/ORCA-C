/*
 * Test of compound literals (C99).
 */

#include <stdio.h>

int *p = (int[]){1,2,3};
int *q = &(int[100]){4,5,6}[1];
struct S *s = &(struct S {int i; double d; void *p;}){100,200.5,&p};

int f(struct S s) {
        return s.i;
}

double g(struct S *s) {
        return s->d + s->i;
}

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
        
        if ((int[]){6,7,8}[2] != 8)
                goto Fail;

        if (((char){34} += (long long){53}) != 87)
                goto Fail;

        if ((int){(double){(long){(char){22}}}} != (signed char){22})
                goto Fail;
        
        if (((struct S*)((struct S){0,-.5,&(struct S){-12,14,0}}.p))->d != 14.)
                goto Fail;
        
        if (f((struct S){f((struct S){-12,14,0}),23.5}) != -12)
                goto Fail;
        
        if (g(&(struct S){5,2.5,&(char){7}}) != 7.5)
                goto Fail;
        
        if ((char[100]){12}[99] != 0)
                goto Fail;
        
        if ((char[]){"Hello world"}[10] != 'd')
                goto Fail;

        if ((char[100]){"Hello world"}[50] != '\0')
                goto Fail;

        printf ("Passed Conformance Test c99complit\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99complit\n");
}
