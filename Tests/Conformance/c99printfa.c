/*
 * Test 'a' and 'A' conversions in printf (C99).
 *
 * This makes certain assumptions about implementation-defined
 * behavior like the positioning of bits in hex float output.
 */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <fenv.h>

#pragma STDC FENV_ACCESS ON

int main(void) {
        char buf[100];
        
        snprintf(buf, sizeof(buf), "%.15La %0.10LA", 123.0L, -234.0L);
        if (strcmp(buf, "0xf.600000000000000p+3 -0XE.A000000000P+4"))
                goto Fail;

        snprintf(buf, sizeof(buf), "% 10.15La", 123.0L);
        if (strcmp(buf, " 0xf.600000000000000p+3"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%+ 25.15La", 123.0L);
        if (strcmp(buf, "  +0xf.600000000000000p+3"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%.0La %#.0La", 123.0L, 123.0L);
        if (strcmp(buf, "0xfp+3 0xf.p+3"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%10.0La", 123.0L);
        if (strcmp(buf, "    0xfp+3"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%0#10.0La", 123.0L);
        if (strcmp(buf, "0x000f.p+3"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%-010.0La", 123.0L);
        if (strcmp(buf, "0xfp+3    "))
                goto Fail;

        snprintf(buf, sizeof(buf), "%La", 0xf.abcdef012345678p-16000L);
        if (strcmp(buf, "0xf.abcdef012345678p-16000"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%30La", -0xf.abcdef012345678p+16000L);
        if (strcmp(buf, "   -0xf.abcdef012345678p+16000"))
                goto Fail;
        
        snprintf(buf, sizeof(buf), "%.15A", -0.0);
        if (strcmp(buf, "-0X0.000000000000000P+0"))
                goto Fail;
        
        snprintf(buf, sizeof(buf), "%010A", -INFINITY);
        if (strcmp(buf, "      -INF"))
                goto Fail;
        
        snprintf(buf, sizeof(buf), "%A", NAN);
        if (!strstr(buf, "NAN"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%LA", (long double)LDBL_MAX);
        if (strcmp(buf, "0XF.FFFFFFFFFFFFFFFP+16380"))
                goto Fail;

#ifdef __ORCAC__
        snprintf(buf, sizeof(buf), "%.10LA", -(long double)LDBL_MAX);
        if (strcmp(buf, "-0X8.0000000000P+16381"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%.14LA", (long double)LDBL_MAX);
        if (strcmp(buf, "0X8.00000000000000P+16381"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%.14LA", 0XF.FFFFFFFFFFFFFF8P+16380L);
        if (strcmp(buf, "0X8.00000000000000P+16381"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%.14LA", 0XF.FFFFFFFFFFFFFF7P+16380L);
        if (strcmp(buf, "0XF.FFFFFFFFFFFFFFP+16380"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%.6LA", 0XF.1234567p-50L);
        if (strcmp(buf, "0XF.123456P-50"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%.6LA", 0XF.1234568p+500L);
        if (strcmp(buf, "0XF.123456P+500"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%.6LA", -0XF.1234569p+5000L);
        if (strcmp(buf, "-0XF.123457P+5000"))
                goto Fail;

        fesetround(FE_UPWARD);

        snprintf(buf, sizeof(buf), "%.14LA", 0XF.FFFFFFFFFFFFFF7P+16380L);
        if (strcmp(buf, "0X8.00000000000000P+16381"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%.14LA", -0XF.FFFFFFFFFFFFFF7P+16380L);
        if (strcmp(buf, "-0XF.FFFFFFFFFFFFFFP+16380"))
                goto Fail;

        fesetround(FE_DOWNWARD);

        snprintf(buf, sizeof(buf), "%.14LA", -0XF.FFFFFFFFFFFFFF7P+16380L);
        if (strcmp(buf, "-0X8.00000000000000P+16381"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%.14LA", 0XF.FFFFFFFFFFFFFF7P+16380L);
        if (strcmp(buf, "0XF.FFFFFFFFFFFFFFP+16380"))
                goto Fail;
        
        fesetround(FE_TOWARDZERO);

        snprintf(buf, sizeof(buf), "%.14LA", -0XF.FFFFFFFFFFFFFF7P+16380L);
        if (strcmp(buf, "-0XF.FFFFFFFFFFFFFFP+16380"))
                goto Fail;

        snprintf(buf, sizeof(buf), "%.14LA", 0XF.FFFFFFFFFFFFFF7P+16380L);
        if (strcmp(buf, "0XF.FFFFFFFFFFFFFFP+16380"))
                goto Fail;
        
        fesetround(FE_TONEAREST);

        snprintf(buf, sizeof(buf), "%La", (long double)0x1p-16445);
        if (strcmp(buf, "0x0.000000000000002p-16386"))
                goto Fail;
#endif

        printf ("Passed Conformance Test c99printfa\n");
        return 0;

Fail:

        printf ("Failed Conformance Test c99printfa\n");
}
