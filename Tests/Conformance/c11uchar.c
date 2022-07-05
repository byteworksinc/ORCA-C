/*
 * Test <uchar.h> conversion functions (C11).
 */

#include <limits.h>
#include <stdio.h>
#include <uchar.h>
#include <stddef.h>

#if !__STDC_UTF_16__ || !__STDC_UTF_32__
#error "Compiler does not use UTF-16/UTF-32 encodings"
#endif

int main(void) {
        char16_t c16;
        char32_t c32;
        char s[MB_LEN_MAX];
        
        if (mbrtoc16(&c16, "a", 2, NULL) != 1)
                goto Fail;
        if (c16 != u'a')
                goto Fail;
        
        if (mbrtoc32(&c32, "Z", 2, NULL) != 1)
                goto Fail;
        if (c32 != U'Z')
                goto Fail;

        if (c16rtomb(s, u'1', NULL) != 1)
                goto Fail;
        if (s[0] != '1')
                goto Fail;

        if (c32rtomb(s, U',', NULL) != 1)
                goto Fail;
        if (s[0] != ',')
                goto Fail;

        if (mbrtoc16(&c16, "", 1, NULL) != 0)
                goto Fail;
        if (c16 != 0)
                goto Fail;
        
        if (mbrtoc32(&c32, "", 1, NULL) != 0)
                goto Fail;
        if (c32 != 0)
                goto Fail;

#ifdef __ORCAC__
        /* Test conversion from/to Mac OS Roman */
        if (mbrtoc16(&c16, "\x80", 2, NULL) != 1)
                goto Fail;
        if (c16 != u'\u00C4')
                goto Fail;
        
        if (mbrtoc32(&c32, "\xA0", 2, NULL) != 1)
                goto Fail;
        if (c32 != U'\u2020')
                goto Fail;

        if (c16rtomb(s, u'\u2264', NULL) != 1)
                goto Fail;
        if (s[0] != '\xB2')
                goto Fail;

        if (c32rtomb(s, U'\u0152', NULL) != 1)
                goto Fail;
        if (s[0] != '\xCE')
                goto Fail;
#endif

        printf ("Passed Conformance Test c11uchar\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c11uchar\n");
}
