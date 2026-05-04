/*
 * Test C23 additions to <tgmath.h>.
 */

#include <tgmath.h>
#include <stdio.h>

int main(void) {
        if (sizeof(acospi(0.5)) != sizeof(double))
                goto Fail;
        if (sizeof(asinpi(0.5F)) != sizeof(float))
                goto Fail;
        if (sizeof(atanpi(2.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(cospi(5)) != sizeof(double))
                goto Fail;
        if (sizeof(exp10(7LL)) != sizeof(double))
                goto Fail;
        
        if (sizeof(atan2pi(1.0F, 20.0F)) != sizeof(float))
                goto Fail;
        if (sizeof(atan2pi(1.0, 20.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(atan2pi(1.0L, 20.0F)) != sizeof(long double))
                goto Fail;
        if (sizeof(atan2pi(1, 20.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(atan2pi(1LL, 20.0F)) != sizeof(double))
                goto Fail;

        if (sizeof(fsqrt(0.5F)) != sizeof(float))
                goto Fail;
        if (sizeof(fsqrt(1.0)) != sizeof(float))
                goto Fail;
        if (sizeof(fsqrt(2.0L)) != sizeof(float))
                goto Fail;

        if (sizeof(fadd(1.0F, 20.0F)) != sizeof(float))
                goto Fail;
        if (sizeof(fadd(1.0F, 20.0)) != sizeof(float))
                goto Fail;
        if (sizeof(fdiv(1.0F, 20.0L)) != sizeof(float))
                goto Fail;
        if (sizeof(fmul(1.0F, 20)) != sizeof(float))
                goto Fail;
        if (sizeof(fsub(1.0F, 20LL)) != sizeof(float))
                goto Fail;

        if (sizeof(fadd(1.0, 20.0F)) != sizeof(float))
                goto Fail;
        if (sizeof(fadd(1.0, 20.0)) != sizeof(float))
                goto Fail;
        if (sizeof(fdiv(1.0, 20.0L)) != sizeof(float))
                goto Fail;
        if (sizeof(fmul(1.0, 20)) != sizeof(float))
                goto Fail;
        if (sizeof(fsub(1.0, 20LL)) != sizeof(float))
                goto Fail;

        if (sizeof(fadd(1.0L, 20.0F)) != sizeof(float))
                goto Fail;
        if (sizeof(fadd(1.0L, 20.0)) != sizeof(float))
                goto Fail;
        if (sizeof(fdiv(1.0L, 20.0L)) != sizeof(float))
                goto Fail;
        if (sizeof(fmul(1.0L, 20)) != sizeof(float))
                goto Fail;
        if (sizeof(fsub(1.0L, 20LL)) != sizeof(float))
                goto Fail;

        if (sizeof(fadd(1, 20.0F)) != sizeof(float))
                goto Fail;
        if (sizeof(fadd(1, 20.0)) != sizeof(float))
                goto Fail;
        if (sizeof(fdiv(1, 20.0L)) != sizeof(float))
                goto Fail;
        if (sizeof(fmul(1, 20)) != sizeof(float))
                goto Fail;
        if (sizeof(fsub(1, 20LL)) != sizeof(float))
                goto Fail;

        if (sizeof(fadd(1LL, 20.0F)) != sizeof(float))
                goto Fail;
        if (sizeof(fadd(1LL, 20.0)) != sizeof(float))
                goto Fail;
        if (sizeof(fdiv(1LL, 20.0L)) != sizeof(float))
                goto Fail;
        if (sizeof(fmul(1LL, 20)) != sizeof(float))
                goto Fail;
        if (sizeof(fsub(1LL, 20LL)) != sizeof(float))
                goto Fail;

        if (sizeof(dsqrt(0.5F)) != sizeof(double))
                goto Fail;
        if (sizeof(dsqrt(1.0)) != sizeof(double))
                goto Fail;
        if (sizeof(dsqrt(2.0L)) != sizeof(double))
                goto Fail;

        if (sizeof(dadd(1.0F, 20.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(dadd(1.0F, 20.0)) != sizeof(double))
                goto Fail;
        if (sizeof(ddiv(1.0F, 20.0L)) != sizeof(double))
                goto Fail;
        if (sizeof(dmul(1.0F, 20)) != sizeof(double))
                goto Fail;
        if (sizeof(dsub(1.0F, 20LL)) != sizeof(double))
                goto Fail;

        if (sizeof(dadd(1.0, 20.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(dadd(1.0, 20.0)) != sizeof(double))
                goto Fail;
        if (sizeof(ddiv(1.0, 20.0L)) != sizeof(double))
                goto Fail;
        if (sizeof(dmul(1.0, 20)) != sizeof(double))
                goto Fail;
        if (sizeof(dsub(1.0, 20LL)) != sizeof(double))
                goto Fail;

        if (sizeof(dadd(1.0L, 20.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(dadd(1.0L, 20.0)) != sizeof(double))
                goto Fail;
        if (sizeof(ddiv(1.0L, 20.0L)) != sizeof(double))
                goto Fail;
        if (sizeof(dmul(1.0L, 20)) != sizeof(double))
                goto Fail;
        if (sizeof(dsub(1.0L, 20LL)) != sizeof(double))
                goto Fail;

        if (sizeof(dadd(1, 20.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(dadd(1, 20.0)) != sizeof(double))
                goto Fail;
        if (sizeof(ddiv(1, 20.0L)) != sizeof(double))
                goto Fail;
        if (sizeof(dmul(1, 20)) != sizeof(double))
                goto Fail;
        if (sizeof(dsub(1, 20LL)) != sizeof(double))
                goto Fail;

        if (sizeof(dadd(1LL, 20.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(dadd(1LL, 20.0)) != sizeof(double))
                goto Fail;
        if (sizeof(ddiv(1LL, 20.0L)) != sizeof(double))
                goto Fail;
        if (sizeof(dmul(1LL, 20)) != sizeof(double))
                goto Fail;
        if (sizeof(dsub(1LL, 20LL)) != sizeof(double))
                goto Fail;

        printf ("Passed Conformance Test c23tgmath\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23tgmath\n");
}
