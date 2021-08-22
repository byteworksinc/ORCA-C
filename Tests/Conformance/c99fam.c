/*
 * Test use of flexible array member (C99).
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TEST_STRING "123456789"

struct S {
        int i;
        char s[];
};

int main(void) {
        struct S s1, *sp;
        
        s1.i = 123;

        sp = &s1;
        
        if (sp->i != 123)
                goto Fail;
        
        sp = malloc(sizeof(struct S) + sizeof(TEST_STRING));
        if (!sp)
                goto Fail;

        *sp = s1; // only guaranteed to copy i

        if (sp->i != 123)
                goto Fail;

        strcpy(sp->s, TEST_STRING);
        
        if (strcmp (sp->s, TEST_STRING) != 0) {
                free(sp);
                goto Fail;
        }

        free(sp);

        printf ("Passed Conformance Test c99fam\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99fam\n");
}
