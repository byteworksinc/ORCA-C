/*
 * Test floating-point environment access with <fenv.h> (C99).
 */

#pragma STDC FENV_ACCESS ON

#include <fenv.h>
#include <float.h>
#include <stdio.h>

int main(void) {
        double d;
        int i;
        fexcept_t excepts, excepts2 = {0};
        fenv_t env, env2;
        
        feholdexcept(&env);
        
        i = feclearexcept(0);
        if (i != 0) goto Fail;
        i = feclearexcept(FE_INEXACT);
        if (i != 0) goto Fail;
        i = feclearexcept(FE_ALL_EXCEPT);
        if (i != 0) goto Fail;

        d = 1.0;
        d /= 0.0;
        if (fetestexcept(FE_DIVBYZERO) != FE_DIVBYZERO)
                goto Fail;
        i = fegetexceptflag(&excepts, FE_ALL_EXCEPT);
        if (i != 0) goto Fail;
        excepts2 = excepts;

        i = feclearexcept(FE_ALL_EXCEPT);
        if (i != 0) goto Fail;
        if (fetestexcept(FE_ALL_EXCEPT) != 0)
                goto Fail;
        
        i = feraiseexcept(FE_INVALID | FE_UNDERFLOW);
        if (i != 0) goto Fail;
        
        i = fegetexceptflag(&excepts, FE_ALL_EXCEPT);
        if (i != 0) goto Fail;
        if (fetestexcept(FE_ALL_EXCEPT - FE_INEXACT) 
                != (FE_INVALID | FE_UNDERFLOW))
                goto Fail;
        
        i = fesetexceptflag(&excepts2, FE_DIVBYZERO);
        if (fetestexcept(FE_ALL_EXCEPT - FE_INEXACT) 
                != (FE_INVALID | FE_UNDERFLOW | FE_DIVBYZERO))
                goto Fail;

        i = fesetexceptflag(&excepts2, FE_ALL_EXCEPT);
        if (fetestexcept(FE_ALL_EXCEPT) != FE_DIVBYZERO)
                goto Fail;

        i = fetestexcept(0);
        if (i != 0) goto Fail;
        
        i = fesetround(FE_UPWARD);
        if (i != 0) goto Fail;
        i = fegetround();
        if (i != FE_UPWARD) goto Fail;
        if (FLT_ROUNDS != 2) goto Fail;
        
        i = fegetenv(&env);
        if (i != 0) goto Fail;
        
        i = fesetround(FE_DOWNWARD);
        if (i != 0) goto Fail;
        i = fegetround();
        if (i != FE_DOWNWARD) goto Fail;
        if (FLT_ROUNDS != 3) goto Fail;
        
        i = feclearexcept(FE_ALL_EXCEPT);
        if (i != 0) goto Fail;
        i = feholdexcept(&env2);
        if (i != 0) goto Fail;
        
        fesetenv(&env);
        if (i != 0) goto Fail;
        if (fegetround() != FE_UPWARD) goto Fail;
        if (fetestexcept(FE_ALL_EXCEPT) != FE_DIVBYZERO)
                goto Fail;
        
        fesetenv(&env2);
        if (i != 0) goto Fail;
        if (fegetround() != FE_DOWNWARD) goto Fail;
        
        i = feraiseexcept(FE_INVALID | FE_INEXACT);
        if (i != 0) goto Fail;

        feupdateenv(&env2);
        if (i != 0) goto Fail;
        if (fegetround() != FE_DOWNWARD) goto Fail;
        if (fetestexcept(FE_ALL_EXCEPT) != (FE_INVALID | FE_INEXACT))
                goto Fail;

        fesetenv(FE_DFL_ENV);
        if (i != 0) goto Fail;

        printf ("Passed Conformance Test c99fenv\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99fenv\n");
}
