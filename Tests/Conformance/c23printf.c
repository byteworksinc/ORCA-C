/*
 * Test new printf features from C23.
 */

#include <stdio.h>
#include <inttypes.h>
#include <string.h>

int main(void) {
        char s[100];

#if __STDC_VERSION__ >= 202311L
        // printf 'b' conversions for binary
        
        if (sprintf(s, "%b", 12345u) != 14)
                goto Fail;
        if (strcmp(s, "11000000111001") != 0)
                goto Fail;
        if (sprintf(s, "%lb", (unsigned long)0xabcd1234) != 32)
                goto Fail;
        if (strcmp(s, "10101011110011010001001000110100") != 0)
                goto Fail;
        if (sprintf(s, "%#llb", (unsigned long long)0xabcdef1234567890) != 66)
                goto Fail;
        if (strcmp(s, "0b1010101111001101111011110001001000110100010101100111100010010000") != 0)
                goto Fail;
        if (sprintf(s, "%#b", 0u) != 1)
                goto Fail;
        if (strcmp(s, "0") != 0)
                goto Fail;
        if (sprintf(s, "%.5b", 4) != 5)
                goto Fail;
        if (strcmp(s, "00100") != 0)
                goto Fail;
        if (sprintf(s, "%.2b", 4) != 3)
                goto Fail;
        if (strcmp(s, "100") != 0)
                goto Fail;
        if (sprintf(s, "%5b", 4) != 5)
                goto Fail;
        if (strcmp(s, "  100") != 0)
                goto Fail;
        if (sprintf(s, "%2b", 4) != 3)
                goto Fail;
        if (strcmp(s, "100") != 0)
                goto Fail;
        if (sprintf(s, "%5.4b", 4) != 5)
                goto Fail;
        if (strcmp(s, " 0100") != 0)
                goto Fail;
        if (sprintf(s, "%-05.4b", 4) != 5)
                goto Fail;
        if (strcmp(s, "0100 ") != 0)
                goto Fail;
        if (sprintf(s, "%05.4b", 4) != 5)
                goto Fail;
        if (strcmp(s, " 0100") != 0)
                goto Fail;
        if (sprintf(s, "%#010b", 4) != 10)
                goto Fail;
        if (strcmp(s, "0b00000100") != 0)
                goto Fail;
        if (sprintf(s, "%#10b", 4) != 10)
                goto Fail;
        if (strcmp(s, "     0b100") != 0)
                goto Fail;
        if (sprintf(s, "%b %ld", 4, 5L) != 5)
                goto Fail;
        if (strcmp(s, "100 5") != 0)
                goto Fail;
        if (sprintf(s, "%lb %d", 4L, 5) != 5)
                goto Fail;
        if (strcmp(s, "100 5") != 0)
                goto Fail;
        if (sprintf(s, "%d %lb", 4, 5L) != 5)
                goto Fail;
        if (strcmp(s, "4 101") != 0)
                goto Fail;

#ifndef PRIbMAX
#error No PRIbMAX definition.
#endif
#endif

#ifdef PRIBMAX
        // printf 'B' conversions for binary (optional C23 feature)
        
        if (sprintf(s, "%B", 12345u) != 14)
                goto Fail;
        if (strcmp(s, "11000000111001") != 0)
                goto Fail;
        if (sprintf(s, "%lB", (unsigned long)0xabcd1234) != 32)
                goto Fail;
        if (strcmp(s, "10101011110011010001001000110100") != 0)
                goto Fail;
        if (sprintf(s, "%#llB", (unsigned long long)0xabcdef1234567890) != 66)
                goto Fail;
        if (strcmp(s, "0B1010101111001101111011110001001000110100010101100111100010010000") != 0)
                goto Fail;
        if (sprintf(s, "%#B", 0u) != 1)
                goto Fail;
        if (strcmp(s, "0") != 0)
                goto Fail;
        if (sprintf(s, "%.5B", 4) != 5)
                goto Fail;
        if (strcmp(s, "00100") != 0)
                goto Fail;
        if (sprintf(s, "%.2B", 4) != 3)
                goto Fail;
        if (strcmp(s, "100") != 0)
                goto Fail;
        if (sprintf(s, "%5B", 4) != 5)
                goto Fail;
        if (strcmp(s, "  100") != 0)
                goto Fail;
        if (sprintf(s, "%2B", 4) != 3)
                goto Fail;
        if (strcmp(s, "100") != 0)
                goto Fail;
        if (sprintf(s, "%5.4B", 4) != 5)
                goto Fail;
        if (strcmp(s, " 0100") != 0)
                goto Fail;
        if (sprintf(s, "%-05.4B", 4) != 5)
                goto Fail;
        if (strcmp(s, "0100 ") != 0)
                goto Fail;
        if (sprintf(s, "%05.4B", 4) != 5)
                goto Fail;
        if (strcmp(s, " 0100") != 0)
                goto Fail;
        if (sprintf(s, "%#010B", 4) != 10)
                goto Fail;
        if (strcmp(s, "0B00000100") != 0)
                goto Fail;
        if (sprintf(s, "%#10B", 4) != 10)
                goto Fail;
        if (strcmp(s, "     0B100") != 0)
                goto Fail;
        if (sprintf(s, "%B %ld", 4, 5L) != 5)
                goto Fail;
        if (strcmp(s, "100 5") != 0)
                goto Fail;
        if (sprintf(s, "%lB %d", 4L, 5) != 5)
                goto Fail;
        if (strcmp(s, "100 5") != 0)
                goto Fail;
        if (sprintf(s, "%d %lB", 4, 5L) != 5)
                goto Fail;
        if (strcmp(s, "4 101") != 0)
                goto Fail;
#endif

        // specified-width length modifiers

        int8_t i8 = 123;
        int16_t i16 = 12345;
        int32_t i32 = 1234567890;
        int64_t i64 = 1234567890123456789;
        
        if (sprintf(s, "%w8d %w16d %w32d %w64d", i8, i16, i32, i64) != 40)
                goto Fail;
        if (strcmp(s, "123 12345 1234567890 1234567890123456789") != 0)
                goto Fail;
        if (sprintf(s, "%#w8x", 0x1234) != 4)
                goto Fail;
        if (strcmp(s, "0x34") != 0)
                goto Fail;
        if (sprintf(s, "%i %w8n %w16n %w32n %w64n", 123, &i8, &i16, &i32, &i64) != 7)
                goto Fail;
        if (i8 != 4 || i16 != 5 || i32 != 6 || i64 != 7)
                goto Fail;

        uint_least8_t ul8 = 123;
        uint_least16_t ul16 = 12345;
        uint_least32_t ul32 = 1234567890;
        uint_least64_t ul64 = 1234567890123456789;
        
        if (sprintf(s, "%w8u %w16u %w32u %w64u", ul8, ul16, ul32, ul64) != 40)
                goto Fail;
        if (strcmp(s, "123 12345 1234567890 1234567890123456789") != 0)
                goto Fail;

        uint_fast8_t uf8 = 0x12;
        uint_fast16_t uf16 = 0x1234;
        uint_fast32_t uf32 = 0x12345678;
        uint_fast64_t uf64 = 0x1234567890abcdef;
        
        if (sprintf(s, "%wf8x %wf16x %wf32x %wf64x", uf8, uf16, uf32, uf64) != 33)
                goto Fail;
        if (strcmp(s, "12 1234 12345678 1234567890abcdef") != 0)
                goto Fail;

        int_fast8_t if8 = 0x12;
        int_fast16_t if16 = 0x1234;
        int_fast32_t if32 = 0x12345678;
        int_fast64_t if64 = 0x1234567890abcdef;

        if (sprintf(s, "%i %wf8n %wf16n %wf32n %wf64n", 123, &if8, &if16, &if32, &if64) != 7)
                goto Fail;
        if (if8 != 4 || if16 != 5 || if32 != 6 || if64 != 7)
                goto Fail;

#ifndef INT1612345678901234567890_MAX
        if (fprintf(stdout, "%w1612345678901234567890d") >= 0)
                goto Fail;
#endif

        printf ("Passed Conformance Test c23printf\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23printf\n");
}
