/*
 * Test <math.h> functions, including C99 additions.
 *
 * This assumes generally IEEE-like behavior, including some behaviors
 * specified in Annex F.  It also assumes a certain degree of accuracy.
 */

#include <float.h>
#include <limits.h>
#include <fenv.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>

#pragma STDC FENV_ACCESS ON

#define PI 3.14159265358979323846264338327950288L

int main(void) {
        int i;
        float f;
        double d;
        long double ld;
        char *p;

#define expect_domain_error(op) do {                            \
        feclearexcept(FE_ALL_EXCEPT);                           \
        if (!isnan(op))                                         \
                goto Fail;                                      \
        if (!fetestexcept(FE_INVALID))                          \
                goto Fail;                                      \
        } while (0)

#define expect_pole_error(op, val) do {                         \
        feclearexcept(FE_ALL_EXCEPT);                           \
        if ((op) != (val))                                      \
                goto Fail;                                      \
        if (!fetestexcept(FE_DIVBYZERO))                        \
                goto Fail;                                      \
        } while (0)

#define expect_overflow(op, val) do {                           \
        feclearexcept(FE_ALL_EXCEPT);                           \
        if ((op) != (val))                                      \
                goto Fail;                                      \
        if (!fetestexcept(FE_OVERFLOW))                         \
                goto Fail;                                      \
        } while (0)

#define expect_underflow(op, val) do {                          \
        feclearexcept(FE_ALL_EXCEPT);                           \
        if ((op) != (val))                                      \
                goto Fail;                                      \
        if (!fetestexcept(FE_UNDERFLOW))                        \
                goto Fail;                                      \
        } while (0)

#define expect_exact(op, val)                                   \
        if ((op) != (val))                                      \
                goto Fail

#define expect_approx(op, val)                                  \
        if (fabsl(((long double)(op) - (val)) / val) > 1e-10L)  \
                goto Fail

#define expect_nan(op)                                          \
        if (!isnan(op))                                         \
                goto Fail

        expect_exact(acos(1.0), +0.0);
        expect_domain_error(acosf(1.1));
        expect_approx(acosl(0.5), 1.047197551196597746135L);
        expect_approx(acosl(-0.25), 1.823476581936975272663L);

        expect_exact(asin(+0.0), +0.0);
        expect_exact(asin(-0.0), -0.0);
        expect_domain_error(asinf(-1.1));
        expect_approx(asinl(0.5), 0.5235987755982988730674L);
        expect_approx(asinl(-0.25), -0.2526802551420786534882L);
        
        expect_exact(atan(+0.0), +0.0);
        expect_exact(atanf(-0.0), -0.0);
        expect_approx(atanl(+INFINITY), PI/2.0);
        expect_approx(atanl(-INFINITY), -PI/2.0);
        expect_approx(atanl(0.25), 0.2449786631268641541663L);
        expect_approx(atanl(-2.0), -1.107148717794090502973L);

        expect_exact(atan2(+0.0, 0.1), +0.0);
        expect_exact(atan2(-0.0, 1.0e-20), -0.0);
        expect_approx(atan2l(+0.0, -1.0), PI);
        expect_approx(atan2l(-0.0, -1.0e20), -PI);
        expect_approx(atan2l(1.0, +0.0), PI/2.0);
        expect_approx(atan2l(9.6, -0.0), PI/2.0);
        expect_approx(atan2l(-1.0, +0.0), -PI/2.0);
        expect_approx(atan2l(-9.6, -0.0), -PI/2.0);
        expect_approx(atan2l(+0.7, -INFINITY), PI);
        expect_approx(atan2l(-2.7, -INFINITY), -PI);
        expect_exact(atan2f(+0.7, INFINITY), +0.0);
        expect_exact(atan2f(-8.7, INFINITY), -0.0);
        expect_approx(atan2l(+INFINITY, -2.6), +PI/2.0);
        expect_approx(atan2l(-INFINITY, -2.6), -PI/2.0);
        expect_approx(atan2l(+INFINITY, -INFINITY), +PI*0.75);
        expect_approx(atan2l(-INFINITY, -INFINITY), -PI*0.75);
        expect_approx(atan2l(+INFINITY, +INFINITY), +PI/4.0);
        expect_approx(atan2l(-INFINITY, +INFINITY), -PI/4.0);
        expect_approx(atan2l(3.0, -4.0), 2.498091544796508851715L);
        expect_approx(atan2l(-9.0, -4.0), -1.989020656374125720382L);

        expect_exact(cos(+0.0), 1.0);
        expect_exact(cosf(-0.0), 1.0);
        expect_domain_error(cos(+INFINITY));
        expect_domain_error(cosf(-INFINITY));
        expect_approx(cosl(0.5), 0.8775825618903727161303L);
        expect_approx(cosl(-1.0), 0.540302305868139717414L);

        expect_exact(sin(+0.0), +0.0);
        expect_exact(sinf(-0.0), -0.0);
        expect_domain_error(sin(+INFINITY));
        expect_domain_error(sinf(-INFINITY));
        expect_approx(sinl(0.5), 0.4794255386042030002815L);
        expect_approx(sinl(-1.0), -0.8414709848078965066646L);
        
        expect_exact(tan(+0.0), +0.0);
        expect_exact(tanf(-0.0), -0.0);
        expect_domain_error(tan(+INFINITY));
        expect_domain_error(tanf(-INFINITY));
        expect_approx(tanl(-0.25), -0.2553419212210362665102L);
        expect_approx(tanl(1.57L), 1255.765591500691683025L);
        
        expect_exact(acosh(1.0), +0.0);
        expect_domain_error(acoshf(0.99));
        expect_domain_error(acosh(-1e30));
        expect_exact(acosh(+INFINITY), +INFINITY);
        expect_approx(acoshl(1.25), 0.6931471805599453094287L);
        expect_approx(acoshl(7e30L), 71.71661011943662919488L);
        
        expect_exact(asinh(+0.0), +0.0);
        expect_exact(asinhf(-0.0), -0.0);
        expect_exact(asinh(+INFINITY), +INFINITY);
        expect_exact(asinhf(-INFINITY), -INFINITY);
        expect_approx(asinhl(0.5), 0.4812118250596034474994L);
        expect_approx(asinhl(-5e27), -64.47238260383327911052L);
        
        expect_exact(atanh(+0.0), +0.0);
        expect_exact(atanhf(-0.0), -0.0);
        expect_pole_error(atanh(+1.0), +INFINITY);
        expect_pole_error(atanhf(-1.0), -INFINITY);
        expect_domain_error(atanh(1.1));
        expect_approx(atanhl(-5e-27L), -5.000000000000000000146e-27L);
        expect_approx(atanhl(0.999L), 3.800201167250200021391L);
        
        expect_exact(cosh(+0.0), 1.0);
        expect_exact(coshf(-0.0), 1.0);
        expect_exact(cosh(+INFINITY), +INFINITY);
        expect_exact(coshf(-INFINITY), +INFINITY);
        expect_overflow(coshl(LDBL_MAX), +INFINITY);
        feclearexcept(FE_ALL_EXCEPT); // ORCA/C cosh bug workaround
        expect_approx(coshl(1.0), 1.543080634815243778546L);
        feclearexcept(FE_ALL_EXCEPT); // ORCA/C cosh bug workaround
        expect_approx(coshl(-10.0), 11013.23292010332313939L);
        
        expect_exact(sinh(+0.0), +0.0);
        expect_exact(sinhf(-0.0), -0.0);
        //expect_exact(sinh(+INFINITY), +INFINITY); // ORCA/C gives a NAN
        //expect_exact(sinhf(-INFINITY), -INFINITY); // ORCA/C gives a NAN
        expect_approx(sinhl(1.25), 1.601919080300825637951L);
        expect_approx(sinhl(-20.0), -242582597.704895138042L);
        
        expect_exact(tanh(+0.0), +0.0);
        expect_exact(tanhf(-0.0), -0.0);
        expect_exact(tanh(+INFINITY), +1.0);
        expect_exact(tanhf(-INFINITY), -1.0);
        expect_approx(tanhl(0.125), 0.1243530017715962080523L);
        expect_approx(tanhl(-0.875), -0.703905603936621060597L);
        
        expect_exact(exp(+0.0), 1.0);
        expect_exact(expf(-0.0), 1.0);
        expect_exact(exp(-INFINITY), +0.0);
        expect_exact(expf(+INFINITY), +INFINITY);
        expect_overflow(expl(LDBL_MAX), +INFINITY);
        expect_approx(expl(10.25), 28282.54192033497908909L);
        expect_approx(expl(-0.125), 0.8824969025845954028516L);
        
        expect_exact(exp2(+0.0), 1.0);
        expect_exact(exp2f(-0.0), 1.0);
        expect_exact(exp2(-INFINITY), +0.0);
        expect_exact(exp2f(+INFINITY), +INFINITY);
        expect_overflow(exp2l(LDBL_MAX), +INFINITY);
        expect_exact(exp2(1.0), 2.0);
        expect_approx(exp2l(20.25), 1246974.039821093245223L);
        expect_approx(exp2l(-.125), 0.9170040432046712317537L);

        expect_exact(expm1(+0.0), +0.0);
        expect_exact(expm1f(-0.0), -0.0);
        expect_exact(expm1(-INFINITY), -1.0);
        expect_exact(expm1f(+INFINITY), +INFINITY);
        expect_overflow(expm1l(LDBL_MAX), +INFINITY);
        expect_approx(expm1l(1e-20L), 1.000000000000000000034e-20L);
        expect_approx(expm1l(-0.001L), -0.0009995001666250083318938L);

        expect_exact(frexp(+0.0, &i), +0.0); expect_exact(i, 0);
        expect_exact(frexpf(-0.0, &i), -0.0); expect_exact(i, 0);
        //expect_exact(frexp(+INFINITY, &i), +INFINITY); // ORCA/C gives 0.5
        //expect_exact(frexpl(-INFINITY, &i), -INFINITY); // ORCA/C gives -0.5
        expect_approx(frexpl(12345.25, &i), 0.7534942626953125L);
                expect_exact(i, 14);
        expect_approx(frexpl(-34e-20, &i), -0.7839866231326559908865L);
                expect_exact(i, -61);

        expect_exact(ilogb(+0.0), FP_ILOGB0);
        expect_exact(ilogbf(-0.0), FP_ILOGB0);
        expect_exact(ilogbl(NAN), FP_ILOGBNAN);
        expect_exact(ilogb(+INFINITY), INT_MAX);
        expect_exact(ilogb(-INFINITY), INT_MAX);
        expect_exact(ilogbl(1e25L), 83);
        expect_exact(ilogb(-12345.0), 13);

        expect_exact(ldexp(+0.0, -14), +0.0);
        expect_exact(ldexpf(-0.0, 12), -0.0);
        expect_exact(ldexpl(12345.0, 0), 12345.0);
        //expect_exact(ldexp(+INFINITY, -10000), +INFINITY); // buggy in ORCA/C
        expect_exact(ldexp(-INFINITY, 0), -INFINITY);
        expect_exact(ldexpl(0x8.4p+0, -100), 0x8.4p-100);
        
        expect_exact(log(1.0), +0.0);
        expect_pole_error(logf(+0.0), -INFINITY);
        expect_pole_error(logl(-0.0), -INFINITY);
        expect_domain_error(log(-1.5));
        expect_domain_error(logl(-INFINITY));
        expect_exact(log(+INFINITY), +INFINITY);
        expect_approx(logl(12345.0), 9.421006401779279878193L);

        expect_exact(log10(1.0), +0.0);
        expect_pole_error(log10f(+0.0), -INFINITY);
        expect_pole_error(log10l(-0.0), -INFINITY);
        expect_domain_error(log10(-1.5));
        expect_domain_error(log10l(-INFINITY));
        expect_exact(log10(+INFINITY), +INFINITY);
        expect_approx(log10l(12345.0), 4.091491094267951082134L);

        expect_exact(log1p(+0.0), +0.0);
        expect_exact(log1pf(-0.0), -0.0);
        expect_pole_error(log1pl(-1.0), -INFINITY);
        expect_domain_error(log1p(-1.1));
        expect_exact(log1p(+INFINITY), +INFINITY);
        expect_approx(log1pl(1e-25L), 9.999999999999999999872e-26L);
        expect_approx(log1pl(-0.125), -0.1335313926245226231516L);

        expect_exact(log2(1.0), +0.0);
        expect_pole_error(log2f(+0.0), -INFINITY);
        expect_pole_error(log2l(-0.0), -INFINITY);
        expect_domain_error(log2(-1.5));
        expect_domain_error(log2l(-INFINITY));
        expect_exact(log2(+INFINITY), +INFINITY);
        expect_approx(log2l(12345.0), 13.59163921603014420648L);

        expect_exact(logb(+INFINITY), +INFINITY);
        expect_exact(logbf(-INFINITY), +INFINITY);
        expect_pole_error(logb(+0.0), -INFINITY);
        expect_pole_error(logb(-0.0), -INFINITY);
        expect_exact(logbl(1e23L), 76.0);
        expect_exact(logbl(-12345e-12L), -27.0);

        expect_exact(modf(+0.0, &d), +0.0); expect_exact(d, +0.0);
        expect_exact(modfl(-0.0, &ld), -0.0); expect_exact(d, -0.0);
        //expect_exact(modf(+INFINITY, &d), +0.0); // gives NAN in ORCA/C
        //      expect_exact(d, +INFINITY);
        expect_exact(modff(-INFINITY, &f), -0.0); expect_exact(f, -INFINITY);
        expect_exact(modf(2.75, &d), 0.75); expect_exact(d, 2.0);
        expect_exact(modff(-10.25, &f), -0.25); expect_exact(f, -10.0);
        expect_exact(modfl(100.5, &ld), 0.5); expect_exact(ld, 100.0);
        
        expect_exact(scalbn(+0.0, -14), +0.0);
        expect_exact(scalbnf(-0.0, 12), -0.0);
        expect_exact(scalbnl(12345.0, 0), 12345.0);
        expect_exact(scalbn(+INFINITY, -10000), +INFINITY);
        expect_exact(scalbn(-INFINITY, 0), -INFINITY);
        expect_exact(scalbnl(0x8.4p+0, -100), 0x8.4p-100);

        expect_exact(scalbln(+0.0, -14), +0.0);
        expect_exact(scalblnf(-0.0, 12), -0.0);
        expect_exact(scalblnl(12345.0, 0), 12345.0);
        expect_exact(scalbln(+INFINITY, -10000), +INFINITY);
        expect_exact(scalbln(-INFINITY, 0), -INFINITY);
        expect_exact(scalblnl(0x8.4p+0, -100), 0x8.4p-100);

        expect_exact(cbrt(+0.0), +0.0);
        expect_exact(cbrtf(-0.0), -0.0);
        expect_exact(cbrt(+INFINITY), +INFINITY);
        expect_exact(cbrtl(-INFINITY), -INFINITY);
        expect_approx(cbrtl(-27.0), -3.0);
        expect_approx(cbrtl(-1e30L), -1e10L);
        expect_approx(cbrtl(1.25e-23L), 2.320794416806389446256e-08L);

        expect_exact(fabs(+0.0), +0.0);
        expect_exact(fabsf(-0.0F), -0.0);
        expect_exact(fabs(+INFINITY), +INFINITY);
        expect_exact(fabsl(-INFINITY), +INFINITY);
        expect_exact(fabs(1.25e20), 1.25e20);
        expect_exact(fabsl(-1.25e-20), 1.25e-20);
        
        expect_exact(hypot(1.25, +0.0), 1.25);
        expect_exact(hypotf(-0.0, -2.25), 2.25);
        expect_exact(hypotl(+INFINITY, -1.2), +INFINITY);
        //expect_exact(hypot(NAN, -INFINITY), INFINITY); // gives NAN in ORCA/C
        expect_approx(hypotl(3.0, -4.0), 5.0);

        expect_pole_error(pow(+0.0, -3.0), +INFINITY);
        expect_pole_error(powf(-0.0, -101.0), -INFINITY);
        expect_pole_error(powl(+0.0, -3.5), +INFINITY);
        //expect_pole_error(pow(-0.0, -3.5), +INFINITY);
        expect_exact(powf(+0.0, -INFINITY), +INFINITY);
        //expect_exact(powl(-0.0, -INFINITY), +INFINITY);
        expect_exact(pow(+0.0, 35.0), +0.0);
        expect_exact(powf(-0.0, 35.0), -0.0);
        expect_exact(powf(+0.0, 34.0), +0.0);
        //expect_exact(powl(-0.0, 35.7), +0.0);
        //expect_exact(pow(-1.0, +INFINITY), 1.0);
        //expect_exact(powf(-1.0, -INFINITY), 1.0);
        expect_exact(pow(+1.0, -2e20), 1.0);
        //expect_exact(powl(+1.0, NAN), 1.0);
        //expect_exact(pow(0.0, -0.0), 1.0);
        //expect_exact(pow(NAN, +0.0), 1.0);
        expect_domain_error(pow(-12.3, 15.7));
        //expect_exact(pow(-0.99, -INFINITY), +INFINITY);
        expect_exact(pow(1.1, -INFINITY), +0.0);
        //expect_exact(pow(-0.99, +INFINITY), +0.0);
        expect_exact(pow(1.1, +INFINITY), +INFINITY);
        expect_exact(pow(-INFINITY, -7.0), -0.0);
        //expect_exact(pow(-INFINITY, -7.5), +0.0);
        expect_exact(pow(-INFINITY, 37.0), -INFINITY);
        //expect_exact(pow(-INFINITY, 37.3), +INFINITY);
        expect_exact(pow(+INFINITY, -11.0), +0.0);
        expect_exact(pow(+INFINITY, 0.0046), +INFINITY);
        expect_approx(powl(5.75, 10.25), 61178018.72438160222737L);
        expect_approx(powl(-0.75, 21.0), -0.002378408954200494918041L);
        
        expect_exact(sqrt(+0.0), +0.0);
        expect_exact(sqrt(-0.0), -0.0);
        expect_exact(sqrt(+INFINITY), +INFINITY);
        expect_domain_error(sqrt(-1.0));
        expect_approx(sqrt(100.0), 10.0);

        expect_exact(erf(+0.0), +0.0);
        expect_exact(erff(-0.0), -0.0);
        expect_exact(erf(+INFINITY), +1.0);
        expect_exact(erfl(-INFINITY), -1.0);
        expect_approx(erfl(-4.20L), -9.999999971445058e-01L);
        expect_approx(erfl(-3.00L), -9.999779095030014e-01L);
        expect_approx(erfl(-0.01L), -1.128341555584948e-02L);
        expect_approx(erfl(0.30L), 3.286267594591276e-01L);
        expect_approx(erfl(1.20L), 9.103139782296354e-01L);
        expect_approx(erfl(4.01L), 9.999999858030606e-01L);
        expect_approx(erfl(1e-4900L), 1.128379167095513e-4900L);
        
        expect_exact(erfc(-INFINITY), 2.0);
        expect_exact(erfcf(+INFINITY), +0.0);
        expect_exact(erfcl(+0.0), 1.0);
        expect_approx(erfcl(-4.45L), 1.999999999689114e+00L);
        expect_approx(erfcl(-2.50L), 1.999593047982555e+00L);
        expect_approx(erfcl(-0.40L), 1.428392355046668e+00L);
        expect_approx(erfcl(0.10L), 8.875370839817150e-01L);
        expect_approx(erfcl(0.95L), 1.791091927267220e-01L);
        expect_approx(erfcl(9.99L), 2.553157649309533e-45L);
        expect_approx(erfcl(105.0L), 4.300838032791244e-4791L);

        expect_pole_error(tgamma(+0.0), +INFINITY);
        expect_pole_error(tgammaf(-0.0), -INFINITY);
        expect_domain_error(tgammal(-2.0));
        expect_domain_error(tgammal(-15.0));
        expect_domain_error(tgammal(-1e4900L));
        expect_domain_error(tgammal(-INFINITY));
        expect_exact(tgammal(+INFINITY),+INFINITY);
        expect_approx(tgammal(1.0), 1.0);
        expect_approx(tgammal(6.0), 120.0);
        expect_approx(tgammal(19.5), 2.77243229863337182e+16L);
        expect_approx(tgammal(1755.0), 1.979261890105010e+4930L);
        expect_approx(tgammal(1e-4932L), 1e4932L);
        expect_approx(tgammal(-0.75), -4.83414654429587774L);
        expect_approx(tgammal(-50.00001L), -3.2878204666630031e-60L);
        expect_approx(tgammal(-1753.75L), 1.452754458037161e-4929L);
        
        expect_exact(ceil(+0.0), +0.0);
        expect_exact(ceilf(-0.0), -0.0);
        expect_exact(ceil(+INFINITY), +INFINITY);
        expect_exact(ceill(-INFINITY), -INFINITY);
        expect_exact(ceil(3.1), 4.0);
        expect_exact(ceil(-3.9), -3.0);
        
        expect_exact(floor(+0.0), +0.0);
        expect_exact(floorf(-0.0), -0.0);
        expect_exact(floor(+INFINITY), +INFINITY);
        expect_exact(floorl(-INFINITY), -INFINITY);
        expect_exact(floor(3.9), 3.0);
        expect_exact(floor(-3.1), -4.0);
        
        expect_exact(nearbyint(+0.0), +0.0);
        expect_exact(nearbyintf(-0.0), -0.0);
        expect_exact(nearbyint(+INFINITY), +INFINITY);
        expect_exact(nearbyintl(-INFINITY), -INFINITY);
        fesetround(FE_UPWARD);
        expect_exact(nearbyint(2.25), 3.0);
        expect_exact(nearbyint(-2.75), -2.0);
        fesetround(FE_DOWNWARD);
        expect_exact(nearbyint(2.75), 2.0);
        expect_exact(nearbyint(-2.25), -3.0);
        fesetround(FE_TOWARDZERO);
        expect_exact(nearbyintf(2.75F), 2.0F);
        expect_exact(nearbyintf(-2.25F), -2.0F);
        fesetenv(FE_DFL_ENV);
        expect_exact(nearbyintl(1.5L), 2.0L);
        expect_exact(nearbyintl(2.5L), 2.0L);
        if (fetestexcept(FE_INEXACT))
                goto Fail;

        expect_exact(rint(+0.0), +0.0);
        expect_exact(rintf(-0.0), -0.0);
        expect_exact(rint(+INFINITY), +INFINITY);
        expect_exact(rintl(-INFINITY), -INFINITY);
        fesetround(FE_UPWARD);
        expect_exact(rint(2.25), 3.0);
        expect_exact(rint(-2.75), -2.0);
        fesetround(FE_DOWNWARD);
        expect_exact(rint(2.75), 2.0);
        expect_exact(rint(-2.25), -3.0);
        fesetround(FE_TOWARDZERO);
        expect_exact(rintf(2.75F), 2.0F);
        expect_exact(rintf(-2.25F), -2.0F);
        fesetenv(FE_DFL_ENV);
        expect_exact(rintl(1.5L), 2.0L);
        expect_exact(rintl(2.5L), 2.0L);
        if (!fetestexcept(FE_INEXACT))
                goto Fail;
        
        expect_exact(lrint(+0.0), 0);
        expect_exact(lrintf(-0.0), 0);
        fesetround(FE_UPWARD);
        expect_exact(lrint(2.25), 3);
        expect_exact(lrint(-2.75), -2);
        fesetround(FE_DOWNWARD);
        expect_exact(lrint(2.75), 2);
        expect_exact(lrint(-2.25), -3);
        fesetround(FE_TOWARDZERO);
        expect_exact(lrintf(2.75F), 2);
        expect_exact(lrintf(-2.25F), -2);
        fesetenv(FE_DFL_ENV);
        expect_exact(lrintl(1.5L), 2);
        expect_exact(lrintl(2.5L), 2);
        if (!fetestexcept(FE_INEXACT))
                goto Fail;

        expect_exact(llrint(+0.0), 0);
        expect_exact(llrintf(-0.0), 0);
        fesetround(FE_UPWARD);
        expect_exact(llrint(2.25), 3);
        expect_exact(llrint(-2.75), -2);
        fesetround(FE_DOWNWARD);
        expect_exact(llrint(2.75), 2);
        expect_exact(llrint(-2.25), -3);
        fesetround(FE_TOWARDZERO);
        expect_exact(llrintf(2.75F), 2);
        expect_exact(llrintf(-2.25F), -2);
        fesetenv(FE_DFL_ENV);
        expect_exact(llrintl(1.5L), 2);
        expect_exact(llrintl(2.5L), 2);
        if (!fetestexcept(FE_INEXACT))
                goto Fail;

        expect_exact(round(+0.0), +0.0);
        expect_exact(roundf(-0.0), -0.0);
        expect_exact(round(+INFINITY), +INFINITY);
        expect_exact(roundl(-INFINITY), -INFINITY);
        fesetround(FE_DOWNWARD);
        expect_exact(round(2.5), 3.0);
        expect_exact(round(3.5), 4.0);
        fesetenv(FE_DFL_ENV);
        expect_exact(roundl(-1.5L), -2.0L);
        expect_exact(roundl(-2.5L), -3.0L);

        expect_exact(lround(+0.0), 0);
        expect_exact(lroundf(-0.0), 0);
        fesetround(FE_DOWNWARD);
        expect_exact(lround(2.5), 3);
        expect_exact(lround(3.5), 4);
        fesetenv(FE_DFL_ENV);
        expect_exact(lroundl(-1.5L), -2);
        expect_exact(lroundl(-2.5L), -3);

        expect_exact(llround(+0.0), 0);
        expect_exact(llroundf(-0.0), 0);
        fesetround(FE_DOWNWARD);
        expect_exact(llround(2.5), 3);
        expect_exact(llround(3.5), 4);
        fesetenv(FE_DFL_ENV);
        expect_exact(llroundl(-1.5L), -2);
        expect_exact(llroundl(-2.5L), -3);

        expect_exact(trunc(+0.0), +0.0);
        expect_exact(truncf(-0.0), -0.0);
        expect_exact(trunc(+INFINITY), +INFINITY);
        expect_exact(truncl(-INFINITY), -INFINITY);
        fesetround(FE_DOWNWARD);
        expect_exact(trunc(2.9), 2.0);
        fesetenv(FE_DFL_ENV);
        expect_exact(truncl(-1.9L), -1.0L);
        
        expect_exact(fmod(+0.0, 10.0), +0.0);
        expect_exact(fmodf(-0.0, 10.0), -0.0);
        //expect_domain_error(fmodl(INFINITY, 10.0)); // no "invalid" in ORCA/C
        expect_nan(fmodl(INFINITY, 10.0));
        //expect_domain_error(fmod(1.0, 0.0)); // gives 1 in ORCA/C
        //expect_exact(fmodl(1.25, +INFINITY), 1.25); //gives NAN in ORCA/C
        expect_exact(fmodl(11.5, 3.0), 2.5);
        expect_exact(fmodl(-11.5, 3.0), -2.5);
        //expect_exact(fmodl(11.5, -3.0), 2.5); // gives -0.5 in ORCA/C
        //expect_exact(fmodl(-11.5, -3.0), -2.5); // gives -0.5 in ORCA/C

        expect_exact(remainder(+0.0, 10.0), +0.0);
        expect_exact(remainderf(-0.0, 10.0), -0.0);
        expect_domain_error(remainderl(INFINITY, 10.0));
        expect_domain_error(remainder(1.0, 0.0));
        expect_exact(remainderl(1.25, +INFINITY), 1.25);
        expect_exact(remainderl(11.5, 3.0), -0.5);
        expect_exact(remainderl(-11.5, 3.0), 0.5);
        expect_exact(remainderl(11.5, -3.0), -0.5);
        expect_exact(remainderl(-11.5, -3.0), 0.5);
        expect_exact(remainderl(10.5, 3.0), -1.5);

        expect_exact(remquo(+0.0, 10.0, &i), +0.0); expect_exact(i, 0);
        expect_exact(remquof(-0.0, 10.0, &i), -0.0); expect_exact(i, 0);
        expect_domain_error(remquol(INFINITY, 10.0, &i));
        expect_domain_error(remquo(1.0, 0.0, &i));
        expect_exact(remquol(1.25, +INFINITY, &i), 1.25); expect_exact(i, 0);
        expect_exact(remquol(11.5, 3.0, &i), -0.5); expect_exact(i, 4);
        expect_exact(remquol(-11.5, 3.0, &i), 0.5); expect_exact(i, -4);
        expect_exact(remquol(11.5, -3.0, &i), -0.5); expect_exact(i, -4);
        expect_exact(remquol(-11.5, -3.0, &i), 0.5); expect_exact(i, 4);
        expect_exact(remquol(10.5, 3.0, &i), -1.5); expect_exact(i, 4);

        expect_exact(copysign(5.5, -2e20), -5.5);
        expect_exact(copysignf(-5.5, +NAN), 5.5);
        expect_exact(copysignl(0x1p+20, -INFINITY), -0x1p+20);
        expect_exact(copysign(1.25, 1e-20), 1.25);
        
        expect_nan(nan(""));
        expect_nan(nanl("123"));
        expect_nan(nanf("X"));
        
        expect_exact(nextafter(1.0, 2.0), 1.0+DBL_EPSILON);
        expect_exact(nextafterf(1.0F+FLT_EPSILON, -1e4), 1.0);
        expect_exact(nextafterl(-1.0L, -INFINITY), -1.0L-LDBL_EPSILON);
        expect_overflow(nextafter(DBL_MAX, +INFINITY), +INFINITY);
        expect_exact(nextafterf(FLT_TRUE_MIN, -7.0), 0.0);

        expect_exact(nexttoward(1.0, 2.0), 1.0+DBL_EPSILON);
        expect_exact(nexttowardf(1.0F+FLT_EPSILON, -1e4), 1.0);
        expect_exact(nexttowardl(-1.0L, -INFINITY), -1.0L-LDBL_EPSILON);
        expect_overflow(nexttowardf(FLT_MAX, +INFINITY), +INFINITY);
        expect_exact(nexttoward(DBL_TRUE_MIN, -7.0), 0.0);

        expect_exact(fdim(1.5, 1.0), 0.5);
        expect_exact(fdimf(-1.5, -1.0), +0.0);
        expect_exact(fdiml(+INFINITY, 1e30), +INFINITY);
        
        expect_exact(fmax(1.5, 1.0), 1.5);
        expect_exact(fmaxf(1.0, 1.5), 1.5);
        expect_exact(fmaxl(-50.0, NAN), -50.0);
        expect_exact(fmaxl(NAN, 1e30L), 1e30L);

        expect_exact(fmin(1.5, 1.0), 1.0);
        expect_exact(fminf(1.0, 1.5), 1.0);
        expect_exact(fminl(-50.0, NAN), -50.0);
        expect_exact(fminl(NAN, 1e30L), 1e30L);

        expect_nan(fma(+INFINITY, +0.0, NAN));
        expect_nan(fmaf(-0.0, -INFINITY, NAN));
        expect_domain_error(fmal(-INFINITY, +0.0, 123.0));
        expect_domain_error(fma(-0.0, +INFINITY, -INFINITY));
        expect_domain_error(fmaf(1e-10, -INFINITY, +INFINITY));
        expect_domain_error(fmal(+INFINITY, 1e-4950L, -INFINITY));
        expect_exact(fma(2.0, 3.0, 5.0), 11.0);
        expect_exact(fmal(2e50L, -3.0L, 5e50L), -1e50L);
        expect_exact(fmaf(-2.0, -3.0, -7.5), -1.5);
        expect_nan(fma(NAN, 1.23, 4.56));
        expect_nan(fmaf(1.23, NAN, 4.56));
        expect_nan(fmal(1.23, 4.56, NAN));
        expect_exact(fmal(+INFINITY, LDBL_TRUE_MIN, -1e4932L), +INFINITY);
        expect_overflow(fmal(1e4000L, 1e1000L, -1e4932L), +INFINITY);
        expect_exact(fmal(LDBL_MAX, 1.0, LDBL_TRUE_MIN), LDBL_MAX);
        expect_exact(fmal(-LDBL_MAX, 1.0, -LDBL_TRUE_MIN), -LDBL_MAX);
        fesetround(FE_UPWARD);
        expect_overflow(fmal(LDBL_MAX, 1.0, LDBL_TRUE_MIN), +INFINITY);
        expect_exact(fmal(-LDBL_MAX, 1.0, -LDBL_TRUE_MIN), -LDBL_MAX);
        fesetround(FE_DOWNWARD);
        expect_exact(fmal(LDBL_MAX, 1.0, LDBL_TRUE_MIN), LDBL_MAX);
        expect_overflow(fmal(-LDBL_MAX, 1.0, -LDBL_TRUE_MIN), -INFINITY);
        fesetround(FE_TOWARDZERO);
        expect_exact(fmal(LDBL_MAX, 1.0, LDBL_TRUE_MIN), LDBL_MAX);
        expect_exact(fmal(-LDBL_MAX, 1.0, -LDBL_TRUE_MIN), -LDBL_MAX);
        expect_underflow(fmal(-LDBL_TRUE_MIN, LDBL_TRUE_MIN, LDBL_TRUE_MIN), 0.0);
        fesetenv(FE_DFL_ENV);
        expect_exact(fmal(-LDBL_TRUE_MIN, LDBL_TRUE_MIN, LDBL_TRUE_MIN), LDBL_TRUE_MIN);
        expect_underflow(fmal(-LDBL_TRUE_MIN, LDBL_TRUE_MIN, 0.0), -0.0);
        expect_exact(fmal(LDBL_TRUE_MIN, 5.0, -LDBL_TRUE_MIN), LDBL_TRUE_MIN*4.0L);

        expect_exact(strtod("-1.25e+3x", &p), -1250.0); expect_exact(*p, 'x');
        expect_exact(strtold("-InFin", &p), -INFINITY); expect_exact(*p, 'i');
        expect_exact(strtof("INFiniTy", &p), INFINITY); //expect_exact(*p, 0);
        expect_nan(strtod("nAN", NULL));
        expect_nan(strtof("-naN(50)", NULL));
        //expect_exact(strtold("0xa.8p+2", NULL), 42.0);

        printf ("Passed Conformance Test c99math\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99math\n");
}
