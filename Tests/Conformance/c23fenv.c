/*
 * Test <fenv.h> functions added in C23.
 */

#pragma STDC FENV_ACCESS ON

#include <fenv.h>
#include <math.h>
#include <stdio.h>

int main(void) {
        femode_t mode;
        fexcept_t except;
        double i;

        // fegetmode/fesetmode tests

        i = rint(0.25);

        if (fesetround(FE_UPWARD))
                goto Fail;
        if (fegetmode(&mode))
                goto Fail;
        if (rint(0.25) != 1.0)
                goto Fail;

        if (fesetround(FE_DOWNWARD))
                goto Fail;
        if (rint(0.25) != 0.0)
                goto Fail;

        if (fesetmode(&mode))
                goto Fail;
        if (fegetround() != FE_UPWARD)
                goto Fail;
        if (rint(0.25) != 1.0)
                goto Fail;

        if (fesetmode(FE_DFL_MODE))
                goto Fail;
        if (rint(0.25) != i)
                goto Fail;

        // fetestexceptflag tests

        if (feclearexcept(FE_ALL_EXCEPT))
                goto Fail;
        if (fegetexceptflag(&except, FE_OVERFLOW | FE_UNDERFLOW | FE_DIVBYZERO))
                goto Fail;
        if (fetestexceptflag(&except, FE_OVERFLOW | FE_UNDERFLOW | FE_DIVBYZERO) != 0)
                goto Fail;

        if (feraiseexcept(FE_OVERFLOW | FE_DIVBYZERO))
                goto Fail;
        if (fetestexceptflag(&except, FE_OVERFLOW | FE_UNDERFLOW | FE_DIVBYZERO) != 0)
                goto Fail;
        if (fegetexceptflag(&except, FE_OVERFLOW | FE_UNDERFLOW | FE_DIVBYZERO))
                goto Fail;
        if (fetestexceptflag(&except, FE_OVERFLOW | FE_UNDERFLOW | FE_DIVBYZERO)
                != (FE_OVERFLOW | FE_DIVBYZERO))
                goto Fail;
        if (fetestexceptflag(&except, FE_OVERFLOW | FE_UNDERFLOW) != FE_OVERFLOW)
                goto Fail;

        printf ("Passed Conformance Test c23fenv\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23fenv\n");
}
