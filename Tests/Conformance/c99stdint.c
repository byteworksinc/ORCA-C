/*
 * Test <stdint.h> and <inttypes.h> (C99).
 */

#include <inttypes.h>
#include <stdio.h>
#include <string.h>

int main(void) {
        // This assumes properties true for ORCA/C
        // and most other typical C implementations.

        int8_t i8 = 0x12;
        uint_least16_t uil16 = 0x1234;
        uint_fast32_t uif32 = 0x12345678;
        uintmax_t uim = 0x1234567890abcdef;
        uintptr_t uip;
        
        void *p = &i8;
        uip = (uintptr_t)p;
        if ((void*)uip != p)
                goto Fail;

        if (INT32_MAX != 0x7fffffff)
                goto Fail;
        
        if (INT_LEAST16_MIN != -32768L)
                goto Fail;
        
        if (UINT_FAST64_MAX != 0xffffffffffffffff)
                goto Fail;
        
        if (PTRDIFF_MIN > -65535L)
                goto Fail;
        
        if (SIZE_MAX < 65535)
                goto Fail;
        
        if (INT32_C(0x123) != 0x123)
                goto Fail;
        
        if (sizeof(INT32_C(0x123)) != 4)
                goto Fail;
        
        if (INT64_C(42) != 42)
                goto Fail;
        
        if (sizeof(INT64_C(42)) != 8)
                goto Fail;

        if (INTMAX_C(0x1234567890abcdef) != 0x1234567890abcdef)
                goto Fail;
        
        if (sizeof(INTMAX_C(0x1234567890abcdef)) < 8)
                goto Fail;

        char s[100];
        sprintf(s, "%" PRId8 " %" PRIuLEAST16 " %#" PRIxFAST32 " %" PRIXMAX, 
                i8, uil16, uif32, uim);
        
        if (strcmp(s, "18 4660 0x12345678 1234567890ABCDEF") != 0)
                goto Fail;
        
        i8 = 0;
        uil16 = 0;
        uif32 = 0;
        uim = 0;
        
        sscanf(s, "%" SCNd8 " %" SCNuLEAST16 " %" SCNxFAST32 " %" SCNxMAX,
                &i8, &uil16, &uif32, &uim);
        
        if (i8 != 0x12)
                goto Fail;

        if (uil16 != 0x1234)
                goto Fail;
        
        if (uif32 != 0x12345678)
                goto Fail;

        if (uim != 0x1234567890abcdef)
                goto Fail;

        printf ("Passed Conformance Test c99stdint\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99stdint\n");
}
