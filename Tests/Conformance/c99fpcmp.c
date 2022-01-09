/*
 * Test floating-point comparison macros (C99).
 */

#include <fenv.h>
#include <math.h>
#include <stdio.h>

float nan_ = NAN;

#pragma STDC FENV_ACCESS ON

int main(void) {
        if (!isgreater(1.0, -3.0))
                goto Fail;
        if (isgreater(-5e20L, -5e20L))
                goto Fail;
        if (isgreater(5.0F, 7.0F))
                goto Fail;
        if (isgreater(nan_, 1.0L))
                goto Fail;
        if (isgreater(-INFINITY, -3.0))
                goto Fail;

        if (!isgreaterequal(1.0, -3.0))
                goto Fail;
        if (!isgreaterequal(-5e20L, -5e20L))
                goto Fail;
        if (isgreaterequal(5.0F, 7.0F))
                goto Fail;
        if (isgreaterequal(nan_, 1.0L))
                goto Fail;
        if (isgreaterequal(-INFINITY, -3.0))
                goto Fail;

        if (isless(1.0, -3.0))
                goto Fail;
        if (isless(-5e20L, -5e20L))
                goto Fail;
        if (!isless(5.0F, 7.0F))
                goto Fail;
        if (isless(nan_, 1.0L))
                goto Fail;
        if (!isless(-INFINITY, -3.0))
                goto Fail;

        if (islessequal(1.0, -3.0))
                goto Fail;
        if (!islessequal(-5e20L, -5e20L))
                goto Fail;
        if (!islessequal(5.0F, 7.0F))
                goto Fail;
        if (islessequal(nan_, 1.0L))
                goto Fail;
        if (!islessequal(-INFINITY, -3.0))
                goto Fail;

        if (!islessgreater(1.0, -3.0))
                goto Fail;
        if (islessgreater(-5e20L, -5e20L))
                goto Fail;
        if (!islessgreater(5.0F, 7.0F))
                goto Fail;
        if (islessgreater(nan_, 1.0L))
                goto Fail;
        if (!islessgreater(-INFINITY, -3.0))
                goto Fail;

        if (isunordered(1.0, -3.0))
                goto Fail;
        if (isunordered(-5e20L, -5e20L))
                goto Fail;
        if (isunordered(5.0F, 7.0F))
                goto Fail;
        if (!isunordered(nan_, 1.0L))
                goto Fail;
        if (isunordered(-INFINITY, -3.0))
                goto Fail;
        if (!isunordered(INFINITY, nan_))
                goto Fail;
        if (!isunordered(nan_, nan_))
                goto Fail;
        
        if (fetestexcept(FE_INVALID))
                goto Fail;

        printf ("Passed Conformance Test c99fpcmp\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99fpcmp\n");
}
