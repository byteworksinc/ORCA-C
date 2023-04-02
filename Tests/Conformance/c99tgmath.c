/*
 * Test <tgmath.h> macros (C99).
 */

#include <tgmath.h>
#include <stdio.h>

int main(void) {
        if (cos(0.0) != 1.0)
                goto Fail;
        if (copysign(1.0L, -3e10F) != -1.0L)
                goto Fail;
        
        if (sizeof(sin(0.0)) != sizeof(double))
                goto Fail;
        if (sizeof(tan(0.5F)) != sizeof(float))
                goto Fail;
        if (sizeof(log(2.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(exp(5)) != sizeof(double))
                goto Fail;
        if (sizeof(sqrt(7LL)) != sizeof(double))
                goto Fail;
        
        if (sizeof(fmax(1.0F, 20.0F)) != sizeof(float))
                goto Fail;
        if (sizeof(fmin(1.0F, 20.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fdim(1.0F, 20.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(hypot(1.0F, 20)) != sizeof(double))
                goto Fail;
        if (sizeof(nextafter(1.0F, 20LL)) != sizeof(double))
                goto Fail;

        if (sizeof(fmax(1.0, 20.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fmin(1.0, 20.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fdim(1.0, 20.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(hypot(1.0, 20)) != sizeof(double))
                goto Fail;
        if (sizeof(nextafter(1.0, 20LL)) != sizeof(double))
                goto Fail;

        if (sizeof(fmax(1.0L, 20.0F)) != sizeof(long double))
                goto Fail;
        if (sizeof(fmin(1.0L, 20.0)) != sizeof(long double))
                goto Fail;
        if (sizeof(fdim(1.0L, 20.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(hypot(1.0L, 20)) != sizeof(long double))
                goto Fail;
        if (sizeof(nextafter(1.0L, 20LL)) != sizeof(long double))
                goto Fail;

        if (sizeof(fmax(1, 20.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fmin(1, 20.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fdim(1, 20.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(hypot(1, 20)) != sizeof(double))
                goto Fail;
        if (sizeof(nextafter(1, 20LL)) != sizeof(double))
                goto Fail;

        if (sizeof(fmax(1LL, 20.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fmin(1LL, 20.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fdim(1LL, 20.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(hypot(1LL, 20)) != sizeof(double))
                goto Fail;
        if (sizeof(nextafter(1LL, 20LL)) != sizeof(double))
                goto Fail;

        if (sizeof(fma(1.0F, 1.0F, 1.0F)) != sizeof(float))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0F, 1.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0F, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0F, 1LL)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0, 1.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0, 1.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0, 1LL)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0L, 1.0F)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0L, 1.0)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0L, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0F, 1.0L, 1LL)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0F, 1L, 1.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0F, 1L, 1.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0F, 1L, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0F, 1L, 1LL)) != sizeof(double))
                goto Fail;

        if (sizeof(fma(1.0, 1.0F, 1.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0F, 1.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0F, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0F, 1LL)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0, 1.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0, 1.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0, 1LL)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0L, 1.0F)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0L, 1.0)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0L, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0, 1.0L, 1LL)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0, 1L, 1.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0, 1L, 1.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1.0, 1L, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0, 1L, 1LL)) != sizeof(double))
                goto Fail;

        if (sizeof(fma(1.0L, 1.0F, 1.0F)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0F, 1.0)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0F, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0F, 1LL)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0, 1.0F)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0, 1.0)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0, 1LL)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0L, 1.0F)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0L, 1.0)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0L, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1.0L, 1LL)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1L, 1.0F)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1L, 1.0)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1L, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1.0L, 1L, 1LL)) != sizeof(long double))
                goto Fail;

        if (sizeof(fma(1LL, 1.0F, 1.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0F, 1.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0F, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0F, 1LL)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0, 1.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0, 1.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0, 1LL)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0L, 1.0F)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0L, 1.0)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0L, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1LL, 1.0L, 1LL)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1LL, 1L, 1.0F)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1LL, 1L, 1.0)) != sizeof(double))
                goto Fail;
        if (sizeof(fma(1LL, 1L, 1.0L)) != sizeof(long double))
                goto Fail;
        if (sizeof(fma(1LL, 1L, 1LL)) != sizeof(double))
                goto Fail;

        printf ("Passed Conformance Test c99tgmath\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99tgmath\n");
}
