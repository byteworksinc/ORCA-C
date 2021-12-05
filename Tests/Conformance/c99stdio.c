/*
 * Test <stdio.h> features from C99.
 */

#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>

int mysscanf(const char *restrict str, const char *restrict fmt, ...);
int mysnprintf(char *restrict str, size_t n, const char *restrict fmt, ...);

int main(void) {
        char s[100] = "abcdef";

        // snprintf tests
        
        if (snprintf(0, 0, "123") != 3)
                goto Fail;
        if (snprintf(s, 0, "123") != 3)
                goto Fail;
        if (memcmp(s, "abcdef", 6) != 0)
                goto Fail;
        if (snprintf(s, 1, "123") != 3)
                goto Fail;
        if (memcmp(s, "\0bcdef", 6) != 0)
                goto Fail;
        if (snprintf(s, 3, "123") != 3)
                goto Fail;
        if (memcmp(s, "12\0def", 6) != 0)
                goto Fail;
        if (snprintf(s, 4, "123") != 3)
                goto Fail;
        if (memcmp(s, "123\0ef", 6) != 0)
                goto Fail;
        s[0] = 'x';
        if (snprintf(s, 0x10000, "123") != 3)
                goto Fail;
        if (memcmp(s, "123\0ef", 6) != 0)
                goto Fail;

        // new length modifiers for printf
        
        signed char sc[2] = {-123, 42};
        unsigned long long ull = 0x2134123412341234;
        uintmax_t uim = 12345678901234567890u;
        size_t sz = 012345;
        ptrdiff_t pd = -12345;
        double d = 123.456;

        mysnprintf(s, 100, "%hhi %#llx %ju %zo %td %lf",
                sc[0], ull, uim, sz, pd, d);
        if (strcmp(s, "-123 0x2134123412341234 12345678901234567890 12345 -12345 123.456000") != 0)
                goto Fail;
        
        sc[0] = 0;
        ull = 0;
        uim = 0;
        sz = 0;
        pd = 0;
        d = 0;
        
        // new length modifiers for scanf
        if (mysscanf(s, "%hhi %llx %ju %zo %td %lf",
                &sc[0], &ull, &uim, &sz, &pd, &d) != 6)
                goto Fail;
        if (sc[0] != -123)
                goto Fail;
        if (ull != 0x2134123412341234)
                goto Fail;
        if (uim != 12345678901234567890u)
                goto Fail;
        if (sz != 012345)
                goto Fail;
        if (pd != -12345)
                goto Fail;
        if (d != (double)123.456)
                goto Fail;
        if (sc[1] != 42)
                goto Fail;


        printf ("Passed Conformance Test c99stdio\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99stdio\n");
}

int mysscanf(const char *restrict str, const char *restrict fmt, ...) {
        va_list va;
        int ret;

        // vsscanf function
        va_start(va, fmt);
        ret = vsscanf(str, fmt, va);
        va_end(va);
        
        return ret;
}

int mysnprintf(char *restrict str, size_t n, const char *restrict fmt, ...) {
        va_list va;
        int ret;

        // vsnprintf function
        va_start(va, fmt);
        ret = vsnprintf(str, n, fmt, va);
        va_end(va);
        
        return ret;
}
