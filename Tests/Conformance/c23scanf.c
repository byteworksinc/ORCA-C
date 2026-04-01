/*
 * Test new scanf features from C23.
 */

#include <stdio.h>
#include <inttypes.h>

int main(void) {
        unsigned char uc;
        unsigned short us;
        unsigned u;
        unsigned long ul;
        unsigned long long ull;
        
        signed char sc;
        short s;
        int i;
        long l;
        long long ll;

#if __STDC_VERSION__ >= 202311L
        // scanf 'b' conversions for binary
        
        if (sscanf(
                "0b01010101 +0B1010101010101010 01010101010101011 "
                "10101010101010101010101010101011 "
                "+1110101010101011101010101010101110101010101010111010101010101000",
                "%hhb%hb %b %lb%llb", &uc, &us, &u, &ul, &ull) != 5)
                goto Fail;
        if (uc != 85)
                goto Fail;
        if (us != 0xaaaa)
                goto Fail;
        if (u != 0xaaab)
                goto Fail;
        if (ul != 0xaaaaaaab)
                goto Fail;
        if (ull != 0xeaabaaabaaabaaa8)
                goto Fail;

        // scanf 'i' conversions handling binary

        if (sscanf(
                "-0b01010101 0B0010101010101010 0b00110101010101011"
                "+0B00101010101010101010101010101011 "
                "0b0110101010101011101010101010101110101010101010111010101010101000",
                "%hhi %hi%i%li %lli", &sc, &s, &i, &l, &ll) != 5)
                goto Fail;
        if (sc != -85)
                goto Fail;
        if (s != 0x2aaa)
                goto Fail;
        if (i != 0x6aab)
                goto Fail;
        if (l != 0x2aaaaaab)
                goto Fail;
        if (ll != 0x6aabaaabaaabaaa8)
                goto Fail;

#ifndef SCNbMAX
#error No SCNbMAX definition.
#endif
#endif

        // specified-width length modifiers

        int8_t i8;
        int16_t i16;
        uint32_t u32;
        uint64_t u64;
        
        int8_t n8 = -1;
        int16_t n16 = -1;
        int32_t n32 = -1;
        int64_t n64 = -1;

        if (sscanf(
                "123 12345 1234567890 0xabcdef1234567890",
                "%w8d %w16i %w32u %w64x%w8n%w16n%w32n%w64n",
                &i8, &i16, &u32, &u64, &n8, &n16, &n32, &n64) != 4)
                goto Fail;
        if (i8 != 123)
                goto Fail;
        if (i16 != 12345)
                goto Fail;
        if (u32 != 1234567890)
                goto Fail;
        if (u64 != 0xabcdef1234567890)
                goto Fail;
        if (n8 != 39 || n16 != 39 || n32 != 39 || n64 != 39)
                goto Fail;

        int_fast8_t f8 = -1;
        int_fast16_t f16;
        uint_fast32_t uf32;
        uint_fast64_t uf64;

        int_fast8_t nf8 = -1;
        int_fast16_t nf16 = -1;
        int_fast32_t nf32 = -1;
        int_fast64_t nf64 = -1;

        if (sscanf(
                "123 12345 1234567890 0xabcdef1234567890",
                "%wf8d %wf16i %wf32u %wf64X%wf8n%wf16n%wf32n%wf64n",
                &f8, &f16, &uf32, &uf64, &nf8, &nf16, &nf32, &nf64) != 4)
                goto Fail;
        if (f8 != 123)
                goto Fail;
        if (f16 != 12345)
                goto Fail;
        if (uf32 != 1234567890)
                goto Fail;
        if (uf64 != 0xabcdef1234567890)
                goto Fail;
        if (nf8 != 39 || nf16 != 39 || nf32 != 39 || nf64 != 39)
                goto Fail;

#ifndef INT1234567890_MAX
        l = 1234567890;
        ll = 0x200bf00bf00bf00b;
        s = 22222;
        if (sscanf("123 4 56", "%i%w1234567890i%li%hn", &i, &ll, &l, &s) != 1)
                 goto Fail;
        if (i != 123)
                goto Fail;
        if (ll != 0x200bf00bf00bf00b)
                goto Fail;
        if (l != 1234567890)
                goto Fail;
        if (s != 22222)
                goto Fail;
#endif

        printf ("Passed Conformance Test c23scanf\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23scanf\n");
}
