/*
 * Test strtold function (C99).
 */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <math.h>
#include <fenv.h>

#pragma STDC FENV_ACCESS ON

void fail(void) {
        printf ("Failed Conformance Test c99strtold\n");
        exit(0);
}

void test(const char *str, long double val, size_t len, int err) {
        char *endptr;
        long double result;

        errno = 0;
        result = strtold(str, &endptr);
        if (err >= 0 && errno != err)
                fail();
        if (endptr-str != len)
                fail();
        if (!isnan(val)) {
                if (result != val || !!signbit(result) != !!signbit(val))
                        fail();
        } else {
                if (!isnan(result))
                        fail();
        }
}

int main(void) {
        test("1", 1.0L, 1, 0);
        test("-2.25E-7", -2.25E-7L, 8, 0);
        test("InfiniTy", +INFINITY, 8, 0);
        test("-inFinitx", -INFINITY, 4, 0);
        test("NaN", NAN, 3, 0);
        test(" -nan(123)", NAN, 10, 0);
        test("nan(abC_123)", NAN, 12, 0);
        test("nan(abC_123-)", NAN, 3, 0);
        test("nan(123", NAN, 3, 0);
        test("\t+Nan()", NAN, 7, 0);
        test("-0xF.8p-1", -7.75L, 9, 0);
        test(" +0XAB4fp2", 175420.0L, 10, 0);
        test("0X.23423p-1", 0X.23423p-1L, 11, 0);
        test("0x4353.p+7", 2206080.0L, 10, 0);
        test("0xabcdef0012345678ffffffffffffp123",
                3.7054705751091077761e+70L, 34, 0);
        test("0xabcdef0012345678000000000000p123",
                3.7054705751091077758e+70L, 34, 0);
        test("0x0.0000000000000000000000012345aP50",
                1.61688425235478883124e-14L, 36, 0);
        test("0x1324124.abcd23p-3000", 1.63145601325652579262e-896L, 22, 0);
        test("0x0000000000.000000p1234567890123456789012345678901234567890",
                0.0, 60, 0);
        test("0X1p17000", INFINITY, 9, ERANGE);
        test("0x1.fffffffffffffffep16383",
                1.18973149535723176502e+4932L, 26, 0);
        test("0x1.ffffffffffffffffp16383", INFINITY, 26, ERANGE);
        test("0X1p-16400L", 1.28254056667789211512e-4937L, 10, -1);
        test("0x3abd.232323p-16390", 1.97485962609712244075e-4930L, 20, 0);
        test("0x7.7p-17000", 0.0, 12, -1);
        test("+0x1.8p+", 1.5L, 6, 0);
        test(" \t\f\n\r\v1.25---", 1.25, 10, 0);
        test("0x.p50", 0.0, 1, 0);
        test("  +abc", 0.0, 0, -1);
        test("-0", -0.0, 2, 0);
        test("-0x0p123", -0.0, 8, 0);

        fesetround(FE_UPWARD);
        test("0x8.0000000000000008", 0x8.000000000000001p0L, 20, 0);
        test("0x8.0000000000000009", 0x8.000000000000001p0L, 20, 0);
        test("0x8.0000000000000018", 0x8.000000000000002p0L, 20, 0);
        test("-0x8.0000000000000008", -0x8.000000000000000p0L, 21, 0);
        test("-0x8.0000000000000009", -0x8.000000000000000p0L, 21, 0);
        test("-0x8.0000000000000018", -0x8.000000000000001p0L, 21, 0);
        test("0x8.00000000000000080001", 0x8.000000000000001p0L, 24, 0);

        fesetround(FE_DOWNWARD);
        test("0x8.0000000000000008", 0x8.000000000000000p0L, 20, 0);
        test("0x8.0000000000000009", 0x8.000000000000000p0L, 20, 0);
        test("0x8.0000000000000018", 0x8.000000000000001p0L, 20, 0);
        test("-0x8.0000000000000008", -0x8.000000000000001p0L, 21, 0);
        test("-0x8.0000000000000009", -0x8.000000000000001p0L, 21, 0);
        test("-0x8.0000000000000018", -0x8.000000000000002p0L, 21, 0);
        test("0x8.00000000000000080001", 0x8.000000000000000p0L, 24, 0);
        
        fesetround(FE_TOWARDZERO);
        test("0x8.0000000000000008", 0x8.000000000000000p0L, 20, 0);
        test("0x8.0000000000000009", 0x8.000000000000000p0L, 20, 0);
        test("0x8.0000000000000018", 0x8.000000000000001p0L, 20, 0);
        test("-0x8.0000000000000008", -0x8.000000000000000p0L, 21, 0);
        test("-0x8.0000000000000009", -0x8.000000000000000p0L, 21, 0);
        test("-0x8.0000000000000018", -0x8.000000000000001p0L, 21, 0);
        test("0x8.00000000000000080001", 0x8.000000000000000p0L, 24, 0);

        fesetround(FE_TONEAREST);
        test("0x8.0000000000000008", 0x8.000000000000000p0L, 20, 0);
        test("0x8.0000000000000009", 0x8.000000000000001p0L, 20, 0);
        test("0x8.0000000000000018", 0x8.000000000000002p0L, 20, 0);
        test("-0x8.0000000000000008", -0x8.000000000000000p0L, 21, 0);
        test("-0x8.0000000000000009", -0x8.000000000000001p0L, 21, 0);
        test("-0x8.0000000000000018", -0x8.000000000000002p0L, 21, 0);
        test("0x8.00000000000000080001", 0x8.000000000000001p0L, 24, 0);

        printf ("Passed Conformance Test c99strtold\n");
        return 0;
}