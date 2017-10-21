/* Conformance Test 25.0.26:  Make sure static variabes can be used */

#include   <stdio.h>

static int j;

void main(void)

{
static int i;

asm {
        lda     i
        sta     j
    }
printf ("Passed Conformance Test 25.0.26\n");
}
