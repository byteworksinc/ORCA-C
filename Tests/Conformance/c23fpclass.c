/*
 * Test floating-point classification macros added in C23.
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
        if (iszero(f) || issubnormal(f))
                goto Fail;

        f = NAN;
        if (iszero(f) || issubnormal(f))
                goto Fail;
        
        f = 1.0;
        if (iszero(f) || issubnormal(f))
                goto Fail;
        
        f = FLT_MIN;
        if (iszero(f) || issubnormal(f))
                goto Fail;
        
        f = FLT_MAX;
        if (iszero(f) || issubnormal(f))
                goto Fail;

        f = 0.0;
        if (!iszero(f) || issubnormal(f))
                goto Fail;

        f = FLT_MIN / 2.0;
        if (iszero(f) || !issubnormal(f))
                goto Fail;


        /* double tests */

        d = INFINITY;
        if (iszero(d) || issubnormal(d))
                goto Fail;
                
        d = NAN;
        if (iszero(d) || issubnormal(d))
                goto Fail;

        d = 1.0;
        if (iszero(d) || issubnormal(d))
                goto Fail;
        
        d = DBL_MIN;
        if (iszero(d) || issubnormal(d))
                goto Fail;
        
        d = DBL_MAX;
        if (iszero(d) || issubnormal(d))
                goto Fail;

        d = 0.0;
        if (!iszero(d) || issubnormal(d))
                goto Fail;

        d = DBL_MIN / 2.0;
        if (iszero(d) || !issubnormal(d))
                goto Fail;


        /* long double tests */

        ld = INFINITY;
        if (iszero(ld) || issubnormal(ld))
                goto Fail;
                
        ld = NAN;
        if (iszero(ld) || issubnormal(ld))
                goto Fail;

        ld = 1.0;
        if (iszero(ld) || issubnormal(ld))
                goto Fail;

        ld = LDBL_MIN;
        if (iszero(ld) || issubnormal(ld))
                goto Fail;

        ld = LDBL_MAX;
        if (iszero(ld) || issubnormal(ld))
                goto Fail;

        ld = 0.0;
        if (!iszero(ld) || issubnormal(ld))
                goto Fail;

        ld = LDBL_MIN / 2.0;
        if (iszero(ld) || !issubnormal(ld))
                goto Fail;

        printf ("Passed Conformance Test c23fpclass\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23fpclass\n");

}
