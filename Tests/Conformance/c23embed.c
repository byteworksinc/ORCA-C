/*
 * Test #embed directive (C23).
 */

#include <stdio.h>
#include <string.h>

#define stringize(...) #__VA_ARGS__

#ifdef __ORCAC__
char s0[] = {
#embed <c23embed.c>
,0};
#endif

char s1[] = {
#embed "c23embed.c"
,0};

char s2[] = {
#embed "c23embed.c" __limit__(2)
,0};

char s3[] = {
#embed "c23embed.c" limit(2) prefix('a','b',) suffix(,'c','d') if_empty('x')
,0};

char s4[] = {
#embed "c23embed.c" limit(0) prefix('a','b',) suffix(,'c','d') if_empty('x')
,0};

#define embedfile "c23embed.c"
#define thelimit limit(2ull)
char s5[] = {
#embed embedfile thelimit
,0};

long f(int a, int b) {
        return a*1000L + b;
}

int main(void) {
        if (strcmp(s2, "/*") != 0)
                goto Fail;

        if (strcmp(s3, "ab/*cd") != 0)
                goto Fail;

        if (strcmp(s4, "x") != 0)
                goto Fail;

        if (strcmp(s5, "/*") != 0)
                goto Fail;
        
        if (f(
#embed "c23embed.c" limit(2)
        ) != 47042)
                goto Fail;

        printf ("Passed Conformance Test c23embed\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23embed\n");
}
