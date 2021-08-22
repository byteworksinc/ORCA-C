/*
 * Test universal character names (C99).
 */

#include <stdio.h>
#include <string.h>

int \u00c0\u0300\U0000aBcDaaa123\U000100aB\U000afffd = 38;

int abc\u2465\U00021a34xyz(void) {
        return '\U00000060';
}

int main(void) {
        int a;
        
        a = \u00c0\u0300\uAbCdaaa123\U000100aB\U000a\
fffD;

        if (a != 38)
                goto Fail;

        char c = abc\U00002465\U00021a34xyz();

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
