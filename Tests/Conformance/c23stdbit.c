/*
 * Test <stdbit.h> functions (C23).
 *
 * This assumes 8-bit char, 16-bit short, and 64-bit long long.
 */

#include <limits.h>
#include <stdbit.h>
#include <stdio.h>
#include <stdbool.h>

_Static_assert(__STDC_ENDIAN_LITTLE__ != __STDC_ENDIAN_BIG__);
#ifdef __ORCAC__
_Static_assert(__STDC_ENDIAN_NATIVE__ == __STDC_ENDIAN_LITTLE__);
#endif

_Static_assert(CHAR_WIDTH == 8 && SHRT_WIDTH == 16 && LLONG_WIDTH == 64,
        "Unexpected width for standard integer type");

int main(void) {
#define expect(x) if (!(x)) goto Fail

        // stdc_leading_zeros tests

        expect(stdc_leading_zeros_uc(0) == 8);
        expect(stdc_leading_zeros_uc(0x1e) == 3);
        expect(stdc_leading_zeros_uc(0x80) == 0);

        expect(stdc_leading_zeros_us(0) == 16);
        expect(stdc_leading_zeros_us(0x001f) == 11);
        expect(stdc_leading_zeros_us(0x0100) == 7);
        expect(stdc_leading_zeros_us(0xffff) == 0);

#if INT_WIDTH == 16
        expect(stdc_leading_zeros_ui(0) == 16);
        expect(stdc_leading_zeros_ui(0x001f) == 11);
        expect(stdc_leading_zeros_ui(0x0100) == 7);
        expect(stdc_leading_zeros_ui(0xffff) == 0);
#endif

#if LONG_WIDTH == 32
        expect(stdc_leading_zeros_ul(0) == 32);
        expect(stdc_leading_zeros_ul(0x000001ea) == 23);
        expect(stdc_leading_zeros_ul(0x01ea0000) == 7);
        expect(stdc_leading_zeros_ul(0xcccccccc) == 0);
#endif

        expect(stdc_leading_zeros_ull(0) == 64);
        expect(stdc_leading_zeros_ull(0x00000000000001ea) == 55);
        expect(stdc_leading_zeros_ull(0x0000000001ea0000) == 39);
        expect(stdc_leading_zeros_ull(0x00000000cccccccc) == 32);
        expect(stdc_leading_zeros_ull(0x00000001cccccccc) == 31);
        expect(stdc_leading_zeros_ull(0x0020000101010101) == 10);
        expect(stdc_leading_zeros_ull(0xffffffff00000000) == 0);

        expect(stdc_leading_zeros((unsigned char)0) == CHAR_WIDTH);
        expect(stdc_leading_zeros((unsigned short)0) == SHRT_WIDTH);
        expect(stdc_leading_zeros((unsigned int)0) == INT_WIDTH);
        expect(stdc_leading_zeros((unsigned long)0) == LONG_WIDTH);
        expect(stdc_leading_zeros((unsigned long long)0) == LLONG_WIDTH);
        expect(stdc_leading_zeros((unsigned _BitInt(8))0) == 8);
        expect(stdc_leading_zeros((unsigned _BitInt(16))0) == 16);
        expect(stdc_leading_zeros((unsigned _BitInt(32))0) == 32);
        expect(stdc_leading_zeros((unsigned _BitInt(64))0) == 64);

        // stdc_leading_ones tests
        
        expect(stdc_leading_ones_uc(0) == 0);
        expect(stdc_leading_ones_uc(0x7f) == 0);
        expect(stdc_leading_ones_uc(0x8f) == 1);
        expect(stdc_leading_ones_uc(0xf7) == 4);
        expect(stdc_leading_ones_uc(0xff) == 8);

        expect(stdc_leading_ones_us(0) == 0);
        expect(stdc_leading_ones_us(0x7fff) == 0);
        expect(stdc_leading_ones_us(0x8fff) == 1);
        expect(stdc_leading_ones_us(0xff80) == 9);
        expect(stdc_leading_ones_us(0xffff) == 16);

#if INT_WIDTH == 16
        expect(stdc_leading_ones_ui(0) == 0);
        expect(stdc_leading_ones_ui(0x7fff) == 0);
        expect(stdc_leading_ones_ui(0x8fff) == 1);
        expect(stdc_leading_ones_ui(0xff80) == 9);
        expect(stdc_leading_ones_ui(0xffff) == 16);
#endif

#if LONG_WIDTH == 32
        expect(stdc_leading_ones_ul(0) == 0);
        expect(stdc_leading_ones_ul(0x7fffffff) == 0);
        expect(stdc_leading_ones_ul(0xcfff0123) == 2);
        expect(stdc_leading_ones_ul(0xffff8080) == 17);
        expect(stdc_leading_ones_ul(0xffffffff) == 32);
#endif

        expect(stdc_leading_ones_ull(0) == 0);
        expect(stdc_leading_ones_ull(0x7fffffffffffffff) == 0);
        expect(stdc_leading_ones_ull(0xcfff012312341232) == 2);
        expect(stdc_leading_ones_ull(0xffff808000000000) == 17);
        expect(stdc_leading_ones_ull(0xffffffffc0000000) == 34);
        expect(stdc_leading_ones_ull(0xffffffffffffff00) == 56);
        expect(stdc_leading_ones_ull(0xffffffffffffffff) == 64);

        expect(stdc_leading_ones((unsigned char)-1) == CHAR_WIDTH);
        expect(stdc_leading_ones((unsigned short)-1) == SHRT_WIDTH);
        expect(stdc_leading_ones((unsigned int)-1) == INT_WIDTH);
        expect(stdc_leading_ones((unsigned long)-1) == LONG_WIDTH);
        expect(stdc_leading_ones((unsigned long long)-1) == LLONG_WIDTH);
        expect(stdc_leading_ones((unsigned _BitInt(8))-1) == 8);
        expect(stdc_leading_ones((unsigned _BitInt(16))-1) == 16);
        expect(stdc_leading_ones((unsigned _BitInt(32))-1) == 32);
        expect(stdc_leading_ones((unsigned _BitInt(64))-1) == 64);

        // stdc_trailing_zeros tests
        
        expect(stdc_trailing_zeros_uc(0) == 8);
        expect(stdc_trailing_zeros_uc(0x03) == 0);
        expect(stdc_trailing_zeros_uc(0x02) == 1);
        expect(stdc_trailing_zeros_uc(0x80) == 7);

        expect(stdc_trailing_zeros_us(0) == 16);
        expect(stdc_trailing_zeros_us(0x0003) == 0);
        expect(stdc_trailing_zeros_us(0x0002) == 1);
        expect(stdc_trailing_zeros_us(0xff80) == 7);
        expect(stdc_trailing_zeros_us(0x8000) == 15);

        expect(stdc_trailing_zeros_ui(0) == INT_WIDTH);
        expect(stdc_trailing_zeros_ui(0x0003) == 0);
        expect(stdc_trailing_zeros_ui(0x0002) == 1);
        expect(stdc_trailing_zeros_ui(0xff80) == 7);
        expect(stdc_trailing_zeros_ui(0x8000) == 15);

        expect(stdc_trailing_zeros_ul(0) == LONG_WIDTH);
        expect(stdc_trailing_zeros_ul(0x00000003) == 0);
        expect(stdc_trailing_zeros_ul(0x00000002) == 1);
        expect(stdc_trailing_zeros_ul(0xffffff80) == 7);
        expect(stdc_trailing_zeros_ul(0x00008000) == 15);
        expect(stdc_trailing_zeros_ul(0x00100000) == 20);
        expect(stdc_trailing_zeros_ul(0x80000000) == 31);

        expect(stdc_trailing_zeros_ull(0) == 64);
        expect(stdc_trailing_zeros_ull(0xffff000000000100) == 8);
        expect(stdc_trailing_zeros_ull(0xff00000080000000) == 31);
        expect(stdc_trailing_zeros_ull(0x0000000100000000) == 32);
        expect(stdc_trailing_zeros_ull(0x0f00000000000000) == 56);
        expect(stdc_trailing_zeros_ull(0x8000000000000000) == 63);

        expect(stdc_trailing_zeros((unsigned char)0) == CHAR_WIDTH);
        expect(stdc_trailing_zeros((unsigned short)0) == SHRT_WIDTH);
        expect(stdc_trailing_zeros((unsigned int)0) == INT_WIDTH);
        expect(stdc_trailing_zeros((unsigned long)0) == LONG_WIDTH);
        expect(stdc_trailing_zeros((unsigned long long)0) == LLONG_WIDTH);
        expect(stdc_trailing_zeros((unsigned _BitInt(8))0) == 8);
        expect(stdc_trailing_zeros((unsigned _BitInt(16))0) == 16);
        expect(stdc_trailing_zeros((unsigned _BitInt(32))0) == 32);
        expect(stdc_trailing_zeros((unsigned _BitInt(64))0) == 64);

        // stdc_trailing_ones tests

        expect(stdc_trailing_ones_uc(0) == 0);
        expect(stdc_trailing_ones_uc(0x03) == 2);
        expect(stdc_trailing_ones_uc(0x02) == 0);
        expect(stdc_trailing_ones_uc(0xfe) == 0);
        expect(stdc_trailing_ones_uc(0xff) == 8);

        expect(stdc_trailing_ones_us(0) == 0);
        expect(stdc_trailing_ones_us(0x0003) == 2);
        expect(stdc_trailing_ones_us(0x0002) == 0);
        expect(stdc_trailing_ones_us(0xfffe) == 0);
        expect(stdc_trailing_ones_us(0xffff) == 16);

        expect(stdc_trailing_ones_ui(0) == 0);
        expect(stdc_trailing_ones_ui(0x0003) == 2);
        expect(stdc_trailing_ones_ui(0x0002) == 0);
        expect(stdc_trailing_ones_ui(0xfffe) == 0);
        expect(stdc_trailing_ones_ui(0xffff) == 16);

        expect(stdc_trailing_ones_ul(0) == 0);
        expect(stdc_trailing_ones_ul(0x00000003) == 2);
        expect(stdc_trailing_ones_ul(0x00000002) == 0);
        expect(stdc_trailing_ones_ul(0x007fffff) == 23);
        expect(stdc_trailing_ones_ul(0xfffffffe) == 0);
        expect(stdc_trailing_ones_ul(0xffffffff) == 32);

        expect(stdc_trailing_ones_ull(0) == 0);
        expect(stdc_trailing_ones_ull(0x0000000000000003) == 2);
        expect(stdc_trailing_ones_ull(0x0000000000000002) == 0);
        expect(stdc_trailing_ones_ull(0x00000000007fffff) == 23);
        expect(stdc_trailing_ones_ull(0x0000007fffffffff) == 39);
        expect(stdc_trailing_ones_ull(0x007fffffffffffff) == 55);
        expect(stdc_trailing_ones_ull(0xfffffffffffffffe) == 0);
        expect(stdc_trailing_ones_ull(0xffffffffffffffff) == 64);

        expect(stdc_trailing_ones((unsigned char)-1) == CHAR_WIDTH);
        expect(stdc_trailing_ones((unsigned short)-1) == SHRT_WIDTH);
        expect(stdc_trailing_ones((unsigned int)-1) == INT_WIDTH);
        expect(stdc_trailing_ones((unsigned long)-1) == LONG_WIDTH);
        expect(stdc_trailing_ones((unsigned long long)-1) == LLONG_WIDTH);
        expect(stdc_trailing_ones((unsigned _BitInt(8))-1) == 8);
        expect(stdc_trailing_ones((unsigned _BitInt(16))-1) == 16);
        expect(stdc_trailing_ones((unsigned _BitInt(32))-1) == 32);
        expect(stdc_trailing_ones((unsigned _BitInt(64))-1) == 64);

        // stdc_first_leading_zero tests

        expect(stdc_first_leading_zero_uc(0) == 1);
        expect(stdc_first_leading_zero_uc(0x7f) == 1);
        expect(stdc_first_leading_zero_uc(0x01) == 1);
        expect(stdc_first_leading_zero_uc(0x80) == 2);
        expect(stdc_first_leading_zero_uc(0xfe) == 8);
        expect(stdc_first_leading_zero_uc(0xff) == 0);

        expect(stdc_first_leading_zero_us(0) == 1);
        expect(stdc_first_leading_zero_us(0x7fff) == 1);
        expect(stdc_first_leading_zero_us(0x0001) == 1);
        expect(stdc_first_leading_zero_us(0x8000) == 2);
        expect(stdc_first_leading_zero_us(0xfffe) == 16);
        expect(stdc_first_leading_zero_us(0xffff) == 0);

        expect(stdc_first_leading_zero_ui(0) == 1);
        expect(stdc_first_leading_zero_ui(0x7fff) == 1);
        expect(stdc_first_leading_zero_ui(0x0001) == 1);
#if INT_WIDTH == 16
        expect(stdc_first_leading_zero_ui(0x8000) == 2);
        expect(stdc_first_leading_zero_ui(0xfffe) == 16);
        expect(stdc_first_leading_zero_ui(0xffff) == 0);
#endif

        expect(stdc_first_leading_zero_ul(0) == 1);
        expect(stdc_first_leading_zero_ul(0x7fffffff) == 1);
        expect(stdc_first_leading_zero_ul(0x00000001) == 1);
#if LONG_WIDTH == 32
        expect(stdc_first_leading_zero_ul(0x80000000) == 2);
        expect(stdc_first_leading_zero_ul(0xfffffffe) == 32);
        expect(stdc_first_leading_zero_ul(0xffffffff) == 0);
#endif

        expect(stdc_first_leading_zero_ull(0) == 1);
        expect(stdc_first_leading_zero_ull(0x7fffffffffffffff) == 1);
        expect(stdc_first_leading_zero_ull(0x0000000000000001) == 1);
        expect(stdc_first_leading_zero_ull(0x8000000000000000) == 2);
        expect(stdc_first_leading_zero_ull(0xffff800000000000) == 18);
        expect(stdc_first_leading_zero_ull(0xffffffff80000000) == 34);
        expect(stdc_first_leading_zero_ull(0xfffffffffffffffe) == 64);
        expect(stdc_first_leading_zero_ull(0xffffffffffffffff) == 0);

        expect(stdc_first_leading_zero((unsigned char)-2) == CHAR_WIDTH);
        expect(stdc_first_leading_zero((unsigned short)-2) == SHRT_WIDTH);
        expect(stdc_first_leading_zero((unsigned int)-2) == INT_WIDTH);
        expect(stdc_first_leading_zero((unsigned long)-2) == LONG_WIDTH);
        expect(stdc_first_leading_zero((unsigned long long)-2) == LLONG_WIDTH);
        expect(stdc_first_leading_zero((unsigned _BitInt(8))-2) == 8);
        expect(stdc_first_leading_zero((unsigned _BitInt(16))-2) == 16);
        expect(stdc_first_leading_zero((unsigned _BitInt(32))-2) == 32);
        expect(stdc_first_leading_zero((unsigned _BitInt(64))-2) == 64);

        // stdc_first_leading_one tests

        expect(stdc_first_leading_one_uc(0) == 0);
        expect(stdc_first_leading_one_uc(0x79) == 2);
        expect(stdc_first_leading_one_uc(0x01) == 8);
        expect(stdc_first_leading_one_uc(0x80) == 1);
        expect(stdc_first_leading_one_uc(0xff) == 1);

        expect(stdc_first_leading_one_us(0) == 0);
        expect(stdc_first_leading_one_us(0x79ab) == 2);
        expect(stdc_first_leading_one_us(0x0001) == 16);
        expect(stdc_first_leading_one_us(0x8000) == 1);
        expect(stdc_first_leading_one_us(0xffff) == 1);

        expect(stdc_first_leading_one_ui(0) == 0);
#if INT_WIDTH == 16
        expect(stdc_first_leading_one_ui(0x79ab) == 2);
        expect(stdc_first_leading_one_ui(0x0001) == 16);
        expect(stdc_first_leading_one_ui(0x8000) == 1);
        expect(stdc_first_leading_one_ui(0xffff) == 1);
#endif

        expect(stdc_first_leading_one_ul(0) == 0);
#if LONG_WIDTH == 32
        expect(stdc_first_leading_one_ul(0x79ab1234) == 2);
        expect(stdc_first_leading_one_ul(0x00001234) == 20);
        expect(stdc_first_leading_one_ul(0x00000001) == 32);
        expect(stdc_first_leading_one_ul(0x80000000) == 1);
        expect(stdc_first_leading_one_ul(0xffffffff) == 1);
#endif

        expect(stdc_first_leading_one_ull(0) == 0);
        expect(stdc_first_leading_one_ull(0x79ab12345678abcd) == 2);
        expect(stdc_first_leading_one_ull(0x000012345678abcd) == 20);
        expect(stdc_first_leading_one_ull(0x0000000012345678) == 36);
        expect(stdc_first_leading_one_ull(0x0000000000000001) == 64);
        expect(stdc_first_leading_one_ull(0x8000000000000000) == 1);
        expect(stdc_first_leading_one_ull(0xffffffffffffffff) == 1);

        expect(stdc_first_leading_one((unsigned char)1) == CHAR_WIDTH);
        expect(stdc_first_leading_one((unsigned short)1) == SHRT_WIDTH);
        expect(stdc_first_leading_one((unsigned int)1) == INT_WIDTH);
        expect(stdc_first_leading_one((unsigned long)1) == LONG_WIDTH);
        expect(stdc_first_leading_one((unsigned long long)1) == LLONG_WIDTH);
        expect(stdc_first_leading_one((unsigned _BitInt(8))1) == 8);
        expect(stdc_first_leading_one((unsigned _BitInt(16))1) == 16);
        expect(stdc_first_leading_one((unsigned _BitInt(32))1) == 32);
        expect(stdc_first_leading_one((unsigned _BitInt(64))1) == 64);

        // stdc_first_trailing_zero tests

        expect(stdc_first_trailing_zero_uc(0) == 1);
        expect(stdc_first_trailing_zero_uc(0x01) == 2);
        expect(stdc_first_trailing_zero_uc(0xfb) == 3);
        expect(stdc_first_trailing_zero_uc(0x7f) == 8);
        expect(stdc_first_trailing_zero_uc(0xff) == 0);

        expect(stdc_first_trailing_zero_us(0) == 1);
        expect(stdc_first_trailing_zero_us(0x0001) == 2);
        expect(stdc_first_trailing_zero_us(0xfbff) == 11);
        expect(stdc_first_trailing_zero_us(0x7fff) == 16);
        expect(stdc_first_trailing_zero_us(0xffff) == 0);

        expect(stdc_first_trailing_zero_ui(0) == 1);
        expect(stdc_first_trailing_zero_ui(0x0001) == 2);
        expect(stdc_first_trailing_zero_ui(0xfbff) == 11);
        expect(stdc_first_trailing_zero_ui(0x7fff) == 16);
#if INT_WIDTH == 16
        expect(stdc_first_trailing_zero_ui(0xffff) == 0);
#endif

        expect(stdc_first_trailing_zero_ul(0) == 1);
        expect(stdc_first_trailing_zero_ul(0x00000001) == 2);
        expect(stdc_first_trailing_zero_ul(0xfbffffff) == 27);
        expect(stdc_first_trailing_zero_ul(0x7fffffff) == 32);
#if LONG_WIDTH == 32
        expect(stdc_first_trailing_zero_ul(0xffffffff) == 0);
#endif

        expect(stdc_first_trailing_zero_ull(0) == 1);
        expect(stdc_first_trailing_zero_ull(0x0000000000000001) == 2);
        expect(stdc_first_trailing_zero_ull(0xfffffffffbffffff) == 27);
        expect(stdc_first_trailing_zero_ull(0xfffffbffffffffff) == 43);
        expect(stdc_first_trailing_zero_ull(0x7fffffffffffffff) == 64);
        expect(stdc_first_trailing_zero_ull(0xffffffffffffffff) == 0);

        expect(stdc_first_trailing_zero((unsigned char)SCHAR_MAX) == CHAR_WIDTH);
        expect(stdc_first_trailing_zero((unsigned short)SHRT_MAX) == SHRT_WIDTH);
        expect(stdc_first_trailing_zero((unsigned int)INT_MAX) == INT_WIDTH);
        expect(stdc_first_trailing_zero((unsigned long)LONG_MAX) == LONG_WIDTH);
        expect(stdc_first_trailing_zero((unsigned long long)LLONG_MAX) == LLONG_WIDTH);
        expect(stdc_first_trailing_zero((unsigned _BitInt(8))0x7f) == 8);
        expect(stdc_first_trailing_zero((unsigned _BitInt(16))0x7fff) == 16);
        expect(stdc_first_trailing_zero((unsigned _BitInt(32))0x7fffffff) == 32);
        expect(stdc_first_trailing_zero((unsigned _BitInt(64))0x7fffffffffffffff) == 64);

        // stdc_first_trailing_one tests

        expect(stdc_first_trailing_one_uc(0) == 0);
        expect(stdc_first_trailing_one_uc(0x1e) == 2);
        expect(stdc_first_trailing_one_uc(0x80) == 8);
        expect(stdc_first_trailing_one_uc(0x0f) == 1);

        expect(stdc_first_trailing_one_us(0) == 0);
        expect(stdc_first_trailing_one_us(0x001e) == 2);
        expect(stdc_first_trailing_one_us(0x8000) == 16);
        expect(stdc_first_trailing_one_us(0x0fff) == 1);

        expect(stdc_first_trailing_one_ui(0) == 0);
        expect(stdc_first_trailing_one_ui(0x001e) == 2);
        expect(stdc_first_trailing_one_ui(0x8000) == 16);
        expect(stdc_first_trailing_one_ui(0x0fff) == 1);

        expect(stdc_first_trailing_one_ul(0) == 0);
        expect(stdc_first_trailing_one_ul(0x0000001e) == 2);
        expect(stdc_first_trailing_one_ul(0x80000000) == 32);
        expect(stdc_first_trailing_one_ul(0x0fffffff) == 1);

        expect(stdc_first_trailing_one_ull(0) == 0);
        expect(stdc_first_trailing_one_ull(0x000000000000001e) == 2);
        expect(stdc_first_trailing_one_ull(0xffffffff80000000) == 32);
        expect(stdc_first_trailing_one_ull(0xffff800000000000) == 48);
        expect(stdc_first_trailing_one_ull(0x8000000000000000) == 64);
        expect(stdc_first_trailing_one_ull(0x0fffffffffffffff) == 1);

        expect(stdc_first_trailing_one((unsigned char)(UCHAR_MAX/2+1)) == CHAR_WIDTH);
        expect(stdc_first_trailing_one((unsigned short)(USHRT_MAX/2+1)) == SHRT_WIDTH);
        expect(stdc_first_trailing_one((unsigned int)(UINT_MAX/2+1)) == INT_WIDTH);
        expect(stdc_first_trailing_one((unsigned long)(ULONG_MAX/2+1)) == LONG_WIDTH);
        expect(stdc_first_trailing_one((unsigned long long)(ULLONG_MAX/2+1)) == LLONG_WIDTH);
        expect(stdc_first_trailing_one((unsigned _BitInt(8))0x80) == 8);
        expect(stdc_first_trailing_one((unsigned _BitInt(16))0x8000) == 16);
        expect(stdc_first_trailing_one((unsigned _BitInt(32))0x80000000) == 32);
        expect(stdc_first_trailing_one((unsigned _BitInt(64))0x8000000000000000) == 64);

        // stdc_count_zeros tests

        expect(stdc_count_zeros_uc(0) == 8);
        expect(stdc_count_zeros_uc(0x01) == 7);
        expect(stdc_count_zeros_uc(0xa3) == 4);
        expect(stdc_count_zeros_uc(0x7f) == 1);
        expect(stdc_count_zeros_uc(0xff) == 0);

        expect(stdc_count_zeros_us(0) == 16);
        expect(stdc_count_zeros_us(0x0001) == 15);
        expect(stdc_count_zeros_us(0xa39c) == 8);
        expect(stdc_count_zeros_us(0x7fff) == 1);
        expect(stdc_count_zeros_us(0xffff) == 0);

#if INT_WIDTH == 16
        expect(stdc_count_zeros_ui(0) == 16);
        expect(stdc_count_zeros_ui(0x0001) == 15);
        expect(stdc_count_zeros_ui(0xa39c) == 8);
        expect(stdc_count_zeros_ui(0x7fff) == 1);
        expect(stdc_count_zeros_ui(0xffff) == 0);
#endif

#if LONG_WIDTH == 32
        expect(stdc_count_zeros_ul(0) == 32);
        expect(stdc_count_zeros_ul(0x00000001) == 31);
        expect(stdc_count_zeros_ul(0xa39c1234) == 19);
        expect(stdc_count_zeros_ul(0x7fffffff) == 1);
        expect(stdc_count_zeros_ul(0xffffffff) == 0);
#endif

        expect(stdc_count_zeros_ull(0) == 64);
        expect(stdc_count_zeros_ull(0x0000000000000001) == 63);
        expect(stdc_count_zeros_ull(0xa39c1234fffe0102) == 34);
        expect(stdc_count_zeros_ull(0x7fffffffffffffff) == 1);
        expect(stdc_count_zeros_ull(0xffffffffffffffff) == 0);

        expect(stdc_count_zeros((unsigned char)0) == CHAR_WIDTH);
        expect(stdc_count_zeros((unsigned short)0) == SHRT_WIDTH);
        expect(stdc_count_zeros((unsigned int)0) == INT_WIDTH);
        expect(stdc_count_zeros((unsigned long)0) == LONG_WIDTH);
        expect(stdc_count_zeros((unsigned long long)0) == LLONG_WIDTH);
        expect(stdc_count_zeros((unsigned _BitInt(8))0) == 8);
        expect(stdc_count_zeros((unsigned _BitInt(16))0) == 16);
        expect(stdc_count_zeros((unsigned _BitInt(32))0) == 32);
        expect(stdc_count_zeros((unsigned _BitInt(64))0) == 64);

        // stdc_count_ones tests

        expect(stdc_count_ones_uc(0) == 0);
        expect(stdc_count_ones_uc(0x10) == 1);
        expect(stdc_count_ones_uc(0x13) == 3);
        expect(stdc_count_ones_uc(0xfe) == 7);
        expect(stdc_count_ones_uc(0xff) == 8);

        expect(stdc_count_ones_us(0) == 0);
        expect(stdc_count_ones_us(0x1000) == 1);
        expect(stdc_count_ones_us(0x1375) == 8);
        expect(stdc_count_ones_us(0xfffe) == 15);
        expect(stdc_count_ones_us(0xffff) == 16);

        expect(stdc_count_ones_ui(0) == 0);
        expect(stdc_count_ones_ui(0x1000) == 1);
        expect(stdc_count_ones_ui(0x1375) == 8);
        expect(stdc_count_ones_ui(0xfffe) == 15);
        expect(stdc_count_ones_ui(0xffff) == 16);

        expect(stdc_count_ones_ul(0) == 0);
        expect(stdc_count_ones_ul(0x10000000) == 1);
        expect(stdc_count_ones_ul(0x1375abcd) == 18);
        expect(stdc_count_ones_ul(0xfffffffe) == 31);
        expect(stdc_count_ones_ul(0xffffffff) == 32);

        expect(stdc_count_ones_ull(0) == 0);
        expect(stdc_count_ones_ull(0x1000000000000000) == 1);
        expect(stdc_count_ones_ull(0x1375abcdf0e00102) == 27);
        expect(stdc_count_ones_ull(0xfffffffffffffffe) == 63);
        expect(stdc_count_ones_ull(0xffffffffffffffff) == 64);

        expect(stdc_count_ones((unsigned char)-1) == CHAR_WIDTH);
        expect(stdc_count_ones((unsigned short)-1) == SHRT_WIDTH);
        expect(stdc_count_ones((unsigned int)-1) == INT_WIDTH);
        expect(stdc_count_ones((unsigned long)-1) == LONG_WIDTH);
        expect(stdc_count_ones((unsigned long long)-1) == LLONG_WIDTH);
        expect(stdc_count_ones((unsigned _BitInt(8))-1) == 8);
        expect(stdc_count_ones((unsigned _BitInt(16))-1) == 16);
        expect(stdc_count_ones((unsigned _BitInt(32))-1) == 32);
        expect(stdc_count_ones((unsigned _BitInt(64))-1) == 64);

        // stdc_has_single_bit tests

        expect(stdc_has_single_bit_uc(0) == false);
        expect(stdc_has_single_bit_uc(0x01) == true);
        expect(stdc_has_single_bit_uc(0x80) == true);
        expect(stdc_has_single_bit_uc(0x03) == false);
        expect(stdc_has_single_bit_uc(0xff) == false);

        expect(stdc_has_single_bit_us(0) == false);
        expect(stdc_has_single_bit_us(0x0001) == true);
        expect(stdc_has_single_bit_us(0x8000) == true);
        expect(stdc_has_single_bit_us(0x0208) == false);
        expect(stdc_has_single_bit_us(0xffff) == false);

        expect(stdc_has_single_bit_ui(0) == false);
        expect(stdc_has_single_bit_ui(0x0001) == true);
        expect(stdc_has_single_bit_ui(0x8000) == true);
        expect(stdc_has_single_bit_ui(0x0208) == false);
        expect(stdc_has_single_bit_ui(0xffff) == false);

        expect(stdc_has_single_bit_ul(0) == false);
        expect(stdc_has_single_bit_ul(0x00000001) == true);
        expect(stdc_has_single_bit_ul(0x80000000) == true);
        expect(stdc_has_single_bit_ul(0x02000008) == false);
        expect(stdc_has_single_bit_ul(0xffffffff) == false);

        expect(stdc_has_single_bit_ull(0) == false);
        expect(stdc_has_single_bit_ull(0x0000000000000001) == true);
        expect(stdc_has_single_bit_ull(0x0000000000020000) == true);
        expect(stdc_has_single_bit_ull(0x0000400000000000) == true);
        expect(stdc_has_single_bit_ull(0x8000000000000000) == true);
        expect(stdc_has_single_bit_ull(0x0200000000080000) == false);
        expect(stdc_has_single_bit_ull(0xffffffffffffffff) == false);

        expect(stdc_has_single_bit((unsigned char)(UCHAR_MAX/2+1)));
        expect(stdc_has_single_bit((unsigned short)(USHRT_MAX/2+1)));
        expect(stdc_has_single_bit((unsigned int)(UINT_MAX/2+1)));
        expect(stdc_has_single_bit((unsigned long)(ULONG_MAX/2+1)));
        expect(stdc_has_single_bit((unsigned long long)(ULLONG_MAX/2+1)));
        expect(stdc_has_single_bit((unsigned _BitInt(8))0x80));
        expect(stdc_has_single_bit((unsigned _BitInt(16))0x8000));
        expect(stdc_has_single_bit((unsigned _BitInt(32))0x80000000));
        expect(stdc_has_single_bit((unsigned _BitInt(64))0x8000000000000000));

        // stdc_bit_width tests

        expect(stdc_bit_width_uc(0) == 0);
        expect(stdc_bit_width_uc(0x01) == 1);
        expect(stdc_bit_width_uc(0x7e) == 7);
        expect(stdc_bit_width_uc(0x80) == 8);
        expect(stdc_bit_width_uc(0xff) == 8);

        expect(stdc_bit_width_us(0) == 0);
        expect(stdc_bit_width_us(0x0001) == 1);
        expect(stdc_bit_width_us(0x7ffe) == 15);
        expect(stdc_bit_width_us(0x8000) == 16);
        expect(stdc_bit_width_us(0xffff) == 16);

        expect(stdc_bit_width_ui(0) == 0);
        expect(stdc_bit_width_ui(0x0001) == 1);
        expect(stdc_bit_width_ui(0x7ffe) == 15);
        expect(stdc_bit_width_ui(0x8000) == 16);
        expect(stdc_bit_width_ui(0xffff) == 16);

        expect(stdc_bit_width_ul(0) == 0);
        expect(stdc_bit_width_ul(0x00000001) == 1);
        expect(stdc_bit_width_ul(0x7ffffffe) == 31);
        expect(stdc_bit_width_ul(0x80000000) == 32);
        expect(stdc_bit_width_ul(0xffffffff) == 32);

        expect(stdc_bit_width_ull(0) == 0);
        expect(stdc_bit_width_ull(0x0000000000000001) == 1);
        expect(stdc_bit_width_ull(0x000000007ffffffe) == 31);
        expect(stdc_bit_width_ull(0x00007ffffffffffe) == 47);
        expect(stdc_bit_width_ull(0x7ffffffffffffffe) == 63);
        expect(stdc_bit_width_ull(0x8000000000000000) == 64);
        expect(stdc_bit_width_ull(0xffffffffffffffff) == 64);

        expect(stdc_bit_width((unsigned char)-1) == CHAR_WIDTH);
        expect(stdc_bit_width((unsigned short)-1) == SHRT_WIDTH);
        expect(stdc_bit_width((unsigned int)-1) == INT_WIDTH);
        expect(stdc_bit_width((unsigned long)-1) == LONG_WIDTH);
        expect(stdc_bit_width((unsigned long long)-1) == LLONG_WIDTH);
        expect(stdc_bit_width((unsigned _BitInt(8))-1) == 8);
        expect(stdc_bit_width((unsigned _BitInt(16))-1) == 16);
        expect(stdc_bit_width((unsigned _BitInt(32))-1) == 32);
        expect(stdc_bit_width((unsigned _BitInt(64))-1) == 64);

        // stdc_bit_floor tests

        expect(stdc_bit_floor_uc(0) == 0);
        expect(stdc_bit_floor_uc(0x01) == 0x01);
        expect(stdc_bit_floor_uc(0x7f) == 0x40);
        expect(stdc_bit_floor_uc(0x80) == 0x80);
        expect(stdc_bit_floor_uc(0xff) == 0x80);

        expect(stdc_bit_floor_us(0) == 0);
        expect(stdc_bit_floor_us(0x0001) == 0x0001);
        expect(stdc_bit_floor_us(0x7fff) == 0x4000);
        expect(stdc_bit_floor_us(0x8000) == 0x8000);
        expect(stdc_bit_floor_us(0xffff) == 0x8000);

        expect(stdc_bit_floor_ui(0) == 0);
        expect(stdc_bit_floor_ui(0x0001) == 0x0001);
        expect(stdc_bit_floor_ui(0x7fff) == 0x4000);
        expect(stdc_bit_floor_ui(0x8000) == 0x8000);
        expect(stdc_bit_floor_ui(0xffff) == 0x8000);

        expect(stdc_bit_floor_ul(0) == 0);
        expect(stdc_bit_floor_ul(0x00000001) == 0x00000001);
        expect(stdc_bit_floor_ul(0x7fffffff) == 0x40000000);
        expect(stdc_bit_floor_ul(0x80000000) == 0x80000000);
        expect(stdc_bit_floor_ul(0xffffffff) == 0x80000000);

        expect(stdc_bit_floor_ull(0) == 0);
        expect(stdc_bit_floor_ull(0x0000000000000001) == 0x0000000000000001);
        expect(stdc_bit_floor_ull(0x0000000000020304) == 0x0000000000020000);
        expect(stdc_bit_floor_ull(0x0000000203040506) == 0x0000000200000000);
        expect(stdc_bit_floor_ull(0x7fffffffffffffff) == 0x4000000000000000);
        expect(stdc_bit_floor_ull(0x8000000000000000) == 0x8000000000000000);
        expect(stdc_bit_floor_ull(0xffffffffffffffff) == 0x8000000000000000);

        expect(stdc_bit_floor((unsigned char)-1) == UCHAR_MAX/2+1);
        expect(stdc_bit_floor((unsigned short)-1) == USHRT_MAX/2+1);
        expect(stdc_bit_floor((unsigned int)-1) == UINT_MAX/2+1);
        expect(stdc_bit_floor((unsigned long)-1) == ULONG_MAX/2+1);
        expect(stdc_bit_floor((unsigned long long)-1) == ULLONG_MAX/2+1);
        expect(stdc_bit_floor((unsigned _BitInt(8))-1) == 0x80);
        expect(stdc_bit_floor((unsigned _BitInt(16))-1) == 0x8000);
        expect(stdc_bit_floor((unsigned _BitInt(32))-1) == 0x80000000);
        expect(stdc_bit_floor((unsigned _BitInt(64))-1) == 0x8000000000000000);

        // stdc_bit_ceil tests

        expect(stdc_bit_ceil_uc(0) == 0x01);
        expect(stdc_bit_ceil_uc(0x01) == 0x01);
        expect(stdc_bit_ceil_uc(0x03) == 0x04);
        expect(stdc_bit_ceil_uc(0x7f) == 0x80);
        expect(stdc_bit_ceil_uc(0x80) == 0x80);
        expect(stdc_bit_ceil_uc(0x81) == 0);

        expect(stdc_bit_ceil_us(0) == 0x0001);
        expect(stdc_bit_ceil_us(0x0001) == 0x0001);
        expect(stdc_bit_ceil_us(0x0003) == 0x0004);
        expect(stdc_bit_ceil_us(0x7fff) == 0x8000);
        expect(stdc_bit_ceil_us(0x8000) == 0x8000);
        expect(stdc_bit_ceil_us(0x8001) == 0);

        expect(stdc_bit_ceil_ui(0) == 0x0001);
        expect(stdc_bit_ceil_ui(0x0001) == 0x0001);
        expect(stdc_bit_ceil_ui(0x0003) == 0x0004);
        expect(stdc_bit_ceil_ui(0x7fff) == 0x8000);
        expect(stdc_bit_ceil_ui(0x8000) == 0x8000);
#if INT_WIDTH == 16
        expect(stdc_bit_ceil_ui(0x8001) == 0);
#endif

        expect(stdc_bit_ceil_ul(0) == 0x00000001);
        expect(stdc_bit_ceil_ul(0x00000001) == 0x00000001);
        expect(stdc_bit_ceil_ul(0x00000003) == 0x00000004);
        expect(stdc_bit_ceil_ul(0x7fffffff) == 0x80000000);
        expect(stdc_bit_ceil_ul(0x80000000) == 0x80000000);
#if LONG_WIDTH == 32
        expect(stdc_bit_ceil_ul(0x80000001) == 0);
#endif

        expect(stdc_bit_ceil_ull(0) == 0x0000000000000001);
        expect(stdc_bit_ceil_ull(0x0000000000000001) == 0x0000000000000001);
        expect(stdc_bit_ceil_ull(0x0000000000000003) == 0x0000000000000004);
        expect(stdc_bit_ceil_ull(0x0000000000070000) == 0x0000000000080000);
        expect(stdc_bit_ceil_ull(0x0000000400000001) == 0x0000000800000000);
        expect(stdc_bit_ceil_ull(0x7fffffffffffffff) == 0x8000000000000000);
        expect(stdc_bit_ceil_ull(0x8000000000000000) == 0x8000000000000000);
        expect(stdc_bit_ceil_ull(0x8000000000000001) == 0);

        expect(stdc_bit_ceil((unsigned char)(UCHAR_MAX/2)) == UCHAR_MAX/2+1);
        expect(stdc_bit_ceil((unsigned short)(USHRT_MAX/2)) == USHRT_MAX/2+1);
        expect(stdc_bit_ceil((unsigned int)(UINT_MAX/2)) == UINT_MAX/2+1);
        expect(stdc_bit_ceil((unsigned long)(ULONG_MAX/2)) == ULONG_MAX/2+1);
        expect(stdc_bit_ceil((unsigned long long)(ULLONG_MAX/2)) == ULLONG_MAX/2+1);
        expect(stdc_bit_ceil((unsigned _BitInt(8))0x7f) == 0x80);
        expect(stdc_bit_ceil((unsigned _BitInt(16))0x7fff) == 0x8000);
        expect(stdc_bit_ceil((unsigned _BitInt(32))0x7fffffff) == 0x80000000);
        expect(stdc_bit_ceil((unsigned _BitInt(64))0x7fffffffffffffff) == 0x8000000000000000);

        printf ("Passed Conformance Test c23stdbit\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23stdbit\n");
}
