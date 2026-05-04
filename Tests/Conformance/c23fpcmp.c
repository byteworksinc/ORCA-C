/*
 * Test iseqsig floating-point comparison macro (C23).
 *
 * This test assumes domain errors signal "invalid".
 */

#include <fenv.h>
#include <float.h>
#include <math.h>
#include <stdio.h>

float nan_ = NAN;

#pragma STDC FENV_ACCESS ON

int main(void) {
        if (iseqsig(1.0, 2.0))
                goto Fail;
        if (!iseqsig(3.0, 3.0))
                goto Fail;
        if (!iseqsig(0.0, -0.0))
                goto Fail;
        if (iseqsig(DBL_MIN, 0.0F))
                goto Fail;
        if (!iseqsig(-INFINITY, -INFINITY))
                goto Fail;
        if (fetestexcept(FE_INVALID))
                goto Fail;

        feclearexcept(FE_ALL_EXCEPT);
        if (iseqsig(NAN, 1.0))
                goto Fail;
        if (fetestexcept(FE_INVALID) != FE_INVALID)
                goto Fail;

        feclearexcept(FE_ALL_EXCEPT);
        if (iseqsig(INFINITY, NAN))
                goto Fail;
        if (fetestexcept(FE_INVALID) != FE_INVALID)
                goto Fail;

        feclearexcept(FE_ALL_EXCEPT);
        if (iseqsig(NAN, NAN))
                goto Fail;
        if (fetestexcept(FE_INVALID) != FE_INVALID)
                goto Fail;

        feclearexcept(FE_ALL_EXCEPT);
        if (iseqsig(nan_, 1.0))
                goto Fail;
        if (fetestexcept(FE_INVALID) != FE_INVALID)
                goto Fail;

        feclearexcept(FE_ALL_EXCEPT);
        if (iseqsig(INFINITY, nan_))
                goto Fail;
        if (fetestexcept(FE_INVALID) != FE_INVALID)
                goto Fail;

        feclearexcept(FE_ALL_EXCEPT);
        if (iseqsig(nan_, nan_))
                goto Fail;
        if (fetestexcept(FE_INVALID) != FE_INVALID)
                goto Fail;

        printf ("Passed Conformance Test c23fpcmp\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23fpcmp\n");
}
