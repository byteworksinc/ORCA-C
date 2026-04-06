/*
 * Test strfromd/strfromf/strtfroml (C23).
 */

#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>

int main(void) {
        int ret;
        char buf[100];
        
        ret = strfromd(buf, sizeof(buf), "%f", 123.25);
        if (ret != 10 || strcmp(buf, "123.250000") != 0)
                goto Fail;

        ret = strfroml(buf, sizeof(buf), "%.3F", -123.25L);
        if (ret != 8 || strcmp(buf, "-123.250") != 0)
                goto Fail;

        ret = strfromf(buf, sizeof(buf), "%e", 123.25f);
        if (ret != 12 || strcmp(buf, "1.232500e+02") != 0)
                goto Fail;

        ret = strfroml(buf, sizeof(buf), "%.5E", 9.625e-101L);
        if (ret != 12 || strcmp(buf, "9.62500E-101") != 0)
                goto Fail;

        ret = strfromd(buf, sizeof(buf), "%g", 345.125);
        if (ret != 7 || strcmp(buf, "345.125") != 0)
                goto Fail;

        ret = strfromf(buf, sizeof(buf), "%.2G", 123456.25f);
        if (ret != 7 || strcmp(buf, "1.2E+05") != 0)
                goto Fail;

#ifdef __ORCAC__
        ret = strfromd(buf, sizeof(buf), "%a", 0xabcd.1234p20);
        if (ret != 23 || strcmp(buf, "0xa.bcd123400000000p+32") != 0)
                goto Fail;

        ret = strfroml(buf, sizeof(buf), "%.10A", -0xabcd.1234p-20);
        if (ret != 18 || strcmp(buf, "-0XA.BCD1234000P-8") != 0)
                goto Fail;
#endif

        ret = strfromf(buf, 3, "%f", 123.25);
        if (ret != 10 || strcmp(buf, "12") != 0)
                goto Fail;

        buf[0] = '#';
        ret = strfromd(buf, 0, "%f", 123.25);
        if (ret != 10 || buf[0] != '#')
                goto Fail;

        ret = strfroml(NULL, 0, "%f", 123.25);
        if (ret != 10)
                goto Fail;

        printf ("Passed Conformance Test c23strto\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23strto\n");
}