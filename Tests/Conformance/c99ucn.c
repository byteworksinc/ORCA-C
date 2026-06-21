/*
 * Test universal character names (C99).
 *
 * Note: This assumes C11 or C23 rules for UCNs allowed in identifiers.
 */

#include <stdio.h>
#include <string.h>

int \u00c0\u0300\U0000aBcDaaa123\U000100aB\U000323af = 38;

int abc\u2185\U00021a34xyz(void) {
        return '\U00000060';
}

int main(void) {
        int a;
        
        a = \u00c0\u0300\uAbCdaaa123\U000100aB\U0003\
23aF;

        if (a != 38)
                goto Fail;

        char c = abc\U00002185\U00021a34xyz();

        if (c != '`')
                goto Fail;
        
        char s[] = "\U00000060\u0040\u0024";
        
        if (sizeof s != 4)
                goto Fail;
        
        if (strcmp(s, "`@$") != 0)
                goto Fail;

        printf ("Passed Conformance Test c99ucn\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99ucn\n");
}
