/*
 * Test handling of preprocessing numbers.
 *
 * Most of this applies to C89, but hex float and long long are specific to
 * C99 and later.
 */

#include <stdio.h>
#include <string.h>

#define COMBINE3(a,b,c) a##b##c
#define STRINGIZE(x) #x

int main(void) {
        if (COMBINE3(123,.,456) != 123.456)
                goto Fail;
        if (COMBINE3(1.,08,999999999999999999999999999999999)
                != 1.08999999999999999999999999999999999)
                goto Fail;
        if (COMBINE3(0x,AB,09) != 0xAB09)
                goto Fail;
        if (strcmp(STRINGIZE(.1xyzp+), ".1xyzp+") != 0)
                goto Fail;
        if (strcmp(STRINGIZE(0xaBcD), "0xaBcD") != 0)
                goto Fail;
        if (strcmp(STRINGIZE(089ae-.), "089ae-.") != 0)
                goto Fail;
        if (sizeof(COMBINE3(123,L,L)) < sizeof(long long))
                goto Fail;

        printf ("Passed Conformance Test c99ppnum\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99ppnum\n");
}
