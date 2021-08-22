/*
 * Test static assertions (C11).
 */

#include <stdio.h>
#include <assert.h>

typedef struct {
        int a;
        static_assert(1+1==2, "bad math");
        int b;
} S1;

typedef struct {
        int a;
        int b;
} S2;

_Static_assert(sizeof(S1)==sizeof(S2), "strange struct sizes");

int main(void) {
        static_assert(sizeof(char)==1, "bad char size");

        printf ("Passed Conformance Test c11sassert\n");
        return 0;
}
