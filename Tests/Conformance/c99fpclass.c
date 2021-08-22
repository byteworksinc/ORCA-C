/*
 * Test floating-point classification macros (C99).
 */

#include <float.h>
#include <math.h>
#include <stdio.h>

int main(void) {
        float f;
        double d;
        long double ld;
        
        // These tests assume IEEE-like floating-point behavior.
        
        /* float tests */

        f = INFINITY;
        if (fpclassify(f) != FP_INFINITE)
                goto Fail;
        if (!isinf(f) || isfinite(f) || isnan(f) || isnormal(f))
                goto Fail;
        if (signbit(f) != 0)
                goto Fail;

        f = NAN;
        if (fpclassify(f) != FP_NAN)
                goto Fail;
        if (isinf(f) || isfinite(f) || !isnan(f) || isnormal(f))
                goto Fail;
        
        f = 1.0;
        if (fpclassify(f) != FP_NORMAL)
                goto Fail;
        if (isinf(f) || !isfinite(f) || isnan(f) || !isnormal(f))
                goto Fail;
        if (signbit(f) != 0)
                goto Fail;
        
        f = FLT_MIN;
        if (fpclassify(f) != FP_NORMAL)
                goto Fail;
        if (isinf(f) || !isfinite(f) || isnan(f) || !isnormal(f))
                goto Fail;
        if (signbit(f) != 0)
                goto Fail;
        
        f = FLT_MAX;
        if (fpclassify(f) != FP_NORMAL)
                goto Fail;
        if (isinf(f) || !isfinite(f) || isnan(f) || !isnormal(f))
                goto Fail;
        if (signbit(f) != 0)
                goto Fail;

        f = 0.0;
        if (fpclassify(f) != FP_ZERO)
                goto Fail;
        if (isinf(f) || !isfinite(f) || isnan(f) || isnormal(f))
                goto Fail;
        if (signbit(f) != 0)
                goto Fail;

        f = FLT_MIN / 2.0;
        if (fpclassify(f) != FP_SUBNORMAL)
                goto Fail;
        if (isinf(f) || !isfinite(f) || isnan(f) || isnormal(f))
                goto Fail;
        if (signbit(f) != 0)
                goto Fail;

        f = -INFINITY;
        if (signbit(f) == 0)
                goto Fail;
        
        f = -1.0;
        if (signbit(f) == 0)
                goto Fail;


        /* double tests */

        d = INFINITY;
        if (fpclassify(d) != FP_INFINITE)
                goto Fail;
        if (!isinf(d) || isfinite(d) || isnan(d) || isnormal(d))
                goto Fail;
        if (signbit(d) != 0)
                goto Fail;
                
        d = NAN;
        if (fpclassify(d) != FP_NAN)
                goto Fail;
        if (isinf(d) || isfinite(d) || !isnan(d) || isnormal(d))
                goto Fail;

        d = 1.0;
        if (fpclassify(d) != FP_NORMAL)
                goto Fail;
        if (isinf(d) || !isfinite(d) || isnan(d) || !isnormal(d))
                goto Fail;
        if (signbit(d) != 0)
                goto Fail;
        
        d = DBL_MIN;
        if (fpclassify(d) != FP_NORMAL)
                goto Fail;
        if (isinf(d) || !isfinite(d) || isnan(d) || !isnormal(d))
                goto Fail;
        if (signbit(d) != 0)
                goto Fail;
        
        d = DBL_MAX;
        if (fpclassify(d) != FP_NORMAL)
                goto Fail;
        if (isinf(d) || !isfinite(d) || isnan(d) || !isnormal(d))
                goto Fail;
        if (signbit(d) != 0)
                goto Fail;

        d = 0.0;
        if (fpclassify(d) != FP_ZERO)
                goto Fail;
        if (isinf(d) || !isfinite(d) || isnan(d) || isnormal(d))
                goto Fail;
        if (signbit(d) != 0)
                goto Fail;

        d = DBL_MIN / 2.0;
        if (fpclassify(d) != FP_SUBNORMAL)
                goto Fail;
        if (isinf(d) || !isfinite(d) || isnan(d) || isnormal(d))
                goto Fail;
        if (signbit(d) != 0)
                goto Fail;

        d = -INFINITY;
        if (signbit(d) == 0)
                goto Fail;
        
        d = -1.0;
        if (signbit(d) == 0)
                goto Fail;


        /* long double tests */

        ld = INFINITY;
        if (fpclassify(ld) != FP_INFINITE)
                goto Fail;
        if (!isinf(ld) || isfinite(ld) || isnan(ld) || isnormal(ld))
                goto Fail;
        if (signbit(ld) != 0)
                goto Fail;
                
        ld = NAN;
        if (fpclassify(ld) != FP_NAN)
                goto Fail;
        if (isinf(ld) || isfinite(ld) || !isnan(ld) || isnormal(ld))
                goto Fail;

        ld = 1.0;
        if (fpclassify(ld) != FP_NORMAL)
                goto Fail;
        if (isinf(ld) || !isfinite(ld) || isnan(ld) || !isnormal(ld))
                goto Fail;
        if (signbit(ld) != 0)
                goto Fail;

        ld = LDBL_MIN;
        if (fpclassify(ld) != FP_NORMAL)
                goto Fail;
        if (isinf(ld) || !isfinite(ld) || isnan(ld) || !isnormal(ld))
                goto Fail;
        if (signbit(ld) != 0)
                goto Fail;

        ld = LDBL_MAX;
        if (fpclassify(ld) != FP_NORMAL)
                goto Fail;
        if (isinf(ld) || !isfinite(ld) || isnan(ld) || !isnormal(ld))
                goto Fail;
        if (signbit(ld) != 0)
                goto Fail;

        ld = 0.0;
        if (fpclassify(ld) != FP_ZERO)
                goto Fail;
        if (isinf(ld) || !isfinite(ld) || isnan(ld) || isnormal(ld))
                goto Fail;
        if (signbit(ld) != 0)
                goto Fail;

        ld = LDBL_MIN / 2.0;
        if (fpclassify(ld) != FP_SUBNORMAL)
                goto Fail;
        if (isinf(ld) || !isfinite(ld) || isnan(ld) || isnormal(ld))
                goto Fail;
        if (signbit(ld) != 0)
                goto Fail;

        ld = -INFINITY;
        if (signbit(ld) == 0)
                goto Fail;
        
        ld = -1.0;
        if (signbit(ld) == 0)
                goto Fail;

        printf ("Passed Conformance Test c99fpclass\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99fpclass\n");

}
