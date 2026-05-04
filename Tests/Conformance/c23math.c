/*
 * Test C23 additions to <math.h>.
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
#define LN2 0.693147180559945309417232121458176568L
#define LN10 2.3025850929940456840179914546843642L

int main(void) {
        int i;
        float f,f2;
        double d,d2;
        long double ld,ld2;
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
        if (fabsl(((long double)(op) - (val)) / (val)) > 1e-10L)\
                goto Fail

#define expect_nan(op)                                          \
        if (!isnan(op))                                         \
                goto Fail

        expect_exact(acospi(1.0), +0.0);
        expect_domain_error(acospif(1.1));
        expect_approx(acospil(0.5), 1.047197551196597746135L/PI);
        expect_approx(acospil(-0.25), 1.823476581936975272663L/PI);

        expect_exact(asinpi(+0.0), +0.0);
        expect_exact(asinpi(-0.0), -0.0);
        expect_domain_error(asinpif(-1.1));
        expect_approx(asinpil(0.5), 0.5235987755982988730674L/PI);
        expect_approx(asinpil(-0.25), -0.2526802551420786534882L/PI);
        
        expect_exact(atanpi(+0.0), +0.0);
        expect_exact(atanpif(-0.0), -0.0);
        expect_approx(atanpil(+INFINITY), 0.5);
        expect_approx(atanpil(-INFINITY), -0.5);
        expect_approx(atanpil(0.25), 0.2449786631268641541663L/PI);
        expect_approx(atanpil(-2.0), -1.107148717794090502973L/PI);

        expect_exact(atan2pi(+0.0, 0.1), +0.0);
        expect_exact(atan2pi(-0.0, 1.0e-20), -0.0);
        expect_approx(atan2pil(+0.0, -1.0), 1.0);
        expect_approx(atan2pil(-0.0, -1.0e20), -1.0);
        expect_approx(atan2pil(1.0, +0.0), 0.5);
        expect_approx(atan2pil(9.6, -0.0), 0.5);
        expect_approx(atan2pil(-1.0, +0.0), -0.5);
        expect_approx(atan2pil(-9.6, -0.0), -0.5);
        expect_approx(atan2pil(+0.7, -INFINITY), 1.0);
        expect_approx(atan2pil(-2.7, -INFINITY), -1.0);
        expect_exact(atan2pif(+0.7, INFINITY), +0.0);
        expect_exact(atan2pif(-8.7, INFINITY), -0.0);
        expect_approx(atan2pil(+INFINITY, -2.6), +0.5);
        expect_approx(atan2pil(-INFINITY, -2.6), -0.5);
        expect_approx(atan2pil(+INFINITY, -INFINITY), +0.75);
        expect_approx(atan2pil(-INFINITY, -INFINITY), -0.75);
        expect_approx(atan2pil(+INFINITY, +INFINITY), +0.25);
        expect_approx(atan2pil(-INFINITY, +INFINITY), -0.25);
        expect_approx(atan2pil(3.0, -4.0), 2.498091544796508851715L/PI);
        expect_approx(atan2pil(-9.0, -4.0), -1.989020656374125720382L/PI);

        expect_exact(cospi(+0.0), 1.0);
        expect_exact(cospif(-0.0), 1.0);
        expect_exact(cospil(1.0), -1.0);
        expect_exact(cospil(1000.5), +0.0);
        expect_domain_error(cospi(+INFINITY));
        expect_domain_error(cospif(-INFINITY));
        expect_approx(cospil(0.5/PI), 0.8775825618903727161303L);
        expect_approx(cospil(-1.0/PI), 0.540302305868139717414L);

        expect_exact(sinpi(+0.0), +0.0);
        expect_exact(sinpif(-0.0), -0.0);
        expect_exact(sinpil(1000.0), +0.0);
        expect_exact(sinpil(-1e25), -0.0);
        expect_exact(sinpil(0.5), 1.0);
        expect_exact(sinpil(-0.5), -1.0);
        expect_domain_error(sinpi(+INFINITY));
        expect_domain_error(sinpif(-INFINITY));
        expect_approx(sinpil(0.5/PI), 0.4794255386042030002815L);
        expect_approx(sinpil(-1.0/PI), -0.8414709848078965066646L);
        
        expect_exact(tanpi(+0.0), +0.0);
        expect_exact(tanpif(-0.0), -0.0);
        expect_exact(tanpil(1e25), +0.0);
        expect_exact(tanpif(-43.0), +0.0);
        expect_exact(tanpi(123.0), -0.0);
        expect_exact(tanpil(-7e30), -0.0);
        expect_pole_error(tanpi(1004.5), +INFINITY);
        expect_pole_error(tanpi(-1003.5), +INFINITY);
        expect_pole_error(tanpi(1003.5), -INFINITY);
        expect_pole_error(tanpi(-1004.5), -INFINITY);
        expect_domain_error(tanpi(+INFINITY));
        expect_domain_error(tanpif(-INFINITY));
        expect_approx(tanpil(-0.25/PI), -0.2553419212210362665102L);
        expect_approx(tanpil(1.57L/PI), 1255.765591500691683025L);

        expect_exact(llogb(+0.0), FP_LLOGB0);
        expect_exact(llogbf(-0.0), FP_LLOGB0);
        expect_exact(llogbl(NAN), FP_LLOGBNAN);
        expect_exact(llogb(+INFINITY), LONG_MAX);
        expect_exact(llogb(-INFINITY), LONG_MAX);
        expect_exact(llogbl(1e25L), 83);
        expect_exact(llogb(-12345.0), 13);

        expect_overflow(compoundn(1e300, 1000000000000000000), +INFINITY);
        expect_underflow(compoundn(-0.999999999999, 1000000000000000000), 0.0);
        expect_exact(compoundnf(-0.1, 0.0), 1.0);
        expect_exact(compoundnl(+INFINITY, 0.0), 1.0);
        //expect_exact(compoundnl(NAN, 0.0), 1.0);
        expect_domain_error(compoundn(-1.1, 123));
        expect_pole_error(compoundnf(-1.0, -123), +INFINITY);
        expect_exact(compoundnl(-1.0, 123), +0.0);
        expect_exact(compoundn(+INFINITY, 3), +INFINITY);
        expect_exact(compoundnf(+INFINITY, -3), +0.0);
        expect_approx(compoundnl(0.25, 5), 3.0517578125);
        expect_approx(compoundnl(-0.25, 5), 0.2373046875);
        expect_approx(compoundnl(0.25, -5), 0.32768);
        expect_approx(compoundnl(-0.25, -5), 4.2139917695);

        expect_exact(exp10(+0.0), 1.0);
        expect_exact(exp10f(-0.0), 1.0);
        expect_exact(exp10(-INFINITY), +0.0);
        expect_exact(exp10f(+INFINITY), +INFINITY);
        expect_overflow(exp10l(LDBL_MAX), +INFINITY);
        expect_approx(exp10l(9.0), 1000000000.0);
        expect_approx(exp10l(10.25), 1.7782794100389228012254211951926848e10L);
        expect_approx(exp10l(-0.125), 0.7498942093324558273021842756151364L);

        expect_exact(exp2m1(+0.0), +0.0);
        expect_exact(exp2m1f(-0.0), -0.0);
        expect_exact(exp2m1(-INFINITY), -1.0);
        expect_exact(exp2m1f(+INFINITY), +INFINITY);
        expect_overflow(exp2m1l(LDBL_MAX), +INFINITY);
        expect_approx(exp2m1l(32.0), 4294967295.0);
        expect_approx(exp2m1l(1e-20L), 6.931471805599453094196343865e-21L);
        expect_approx(exp2m1l(-0.001L), -0.000692907009547478077620644636498L);

        expect_exact(exp10m1(+0.0), +0.0);
        expect_exact(exp10m1f(-0.0), -0.0);
        expect_exact(exp10m1(-INFINITY), -1.0);
        expect_exact(exp10m1f(+INFINITY), +INFINITY);
        expect_overflow(exp10m1l(LDBL_MAX), +INFINITY);
        expect_approx(exp10m1l(10.0), 9999999999.0);
        expect_approx(exp10m1l(1e-20L), 2.3025850929940456840445009452e-20L);
        expect_approx(exp10m1l(-0.001L), -0.0022999361774466828055780571462);

        expect_exact(logp1(+0.0), +0.0);
        expect_exact(logp1f(-0.0), -0.0);
        expect_pole_error(logp1l(-1.0), -INFINITY);
        expect_domain_error(logp1(-1.1));
        expect_exact(logp1(+INFINITY), +INFINITY);
        expect_approx(logp1l(1e-25L), 9.999999999999999999872e-26L);
        expect_approx(logp1l(-0.125), -0.1335313926245226231516L);

        expect_exact(log2p1(+0.0), +0.0);
        expect_exact(log2p1f(-0.0), -0.0);
        expect_pole_error(log2p1l(-1.0), -INFINITY);
        expect_domain_error(log2p1(-1.1));
        expect_exact(log2p1(+INFINITY), +INFINITY);
        expect_approx(log2p1l(1.0), 1.0);
        expect_approx(log2p1l(1e-25L), 9.999999999999999999872e-26L/LN2);
        expect_approx(log2p1l(-0.125), -0.1335313926245226231516L/LN2);

        expect_exact(log10p1(+0.0), +0.0);
        expect_exact(log10p1f(-0.0), -0.0);
        expect_pole_error(log10p1l(-1.0), -INFINITY);
        expect_domain_error(log10p1(-1.1));
        expect_exact(log10p1(+INFINITY), +INFINITY);
        expect_approx(log10p1l(9.0), 1.0);
        expect_approx(log10p1l(1e-25L), 9.999999999999999999872e-26L/LN10);
        expect_approx(log10p1l(-0.125), -0.1335313926245226231516L/LN10);

        expect_pole_error(rsqrt(+0.0), +INFINITY);
        expect_pole_error(rsqrtf(-0.0), -INFINITY);
        expect_domain_error(rsqrtl(-1.0));
        expect_exact(rsqrtl(+INFINITY), +0.0);
        expect_approx(rsqrtl(4.0), 0.5);
        expect_approx(rsqrtl(1e300L), 1e-150L);
        expect_approx(rsqrtl(1e-300L), 1e150L);

        expect_exact(pown(1.23, 0), 1.0);
        //expect_exact(pown(0.0, 0), 1.0);
        //expect_exact(pown(+INFINITY, 0), 1.0);
        //expect_exact(pownl(NAN, 0), 1.0);
        expect_pole_error(pownf(+0.0, -123), +INFINITY);
        expect_pole_error(pownl(-0.0, -123), -INFINITY);
        expect_pole_error(pownf(+0.0, -124), +INFINITY);
        expect_pole_error(pownl(-0.0, -124), +INFINITY);
        expect_exact(pown(+0.0, 124), +0.0);
        expect_exact(pown(-0.0, 124), +0.0);
        expect_exact(pown(+0.0, 123), +0.0);
        expect_exact(pown(-0.0, 123), -0.0);
        expect_exact(pown(+INFINITY, -123), +0.0);
        expect_exact(pown(+INFINITY, -124), +0.0);
        expect_exact(pown(+INFINITY, 123), +INFINITY);
        expect_exact(pown(+INFINITY, 124), +INFINITY);
        expect_exact(pown(-INFINITY, -123), -0.0);
        expect_exact(pown(-INFINITY, -124), +0.0);
        expect_exact(pown(-INFINITY, 123), -INFINITY);
        expect_exact(pown(-INFINITY, 124), +INFINITY);
        expect_approx(pownl(-0.75, 21), -0.002378408954200494918041L);
        expect_approx(pownl(1.0, -9223372036854775807-1), 1.0);
        expect_approx(pownl(0x0.fffffffffffff8p0L, -9223372036854775807-1),
                5.2185454343677308411e444L);

        expect_exact(roundeven(+0.0), +0.0);
        expect_exact(roundevenf(-0.0), -0.0);
        expect_exact(roundeven(+INFINITY), +INFINITY);
        expect_exact(roundevenl(-INFINITY), -INFINITY);
        expect_exact(roundeven(3.9), 4.0);
        expect_exact(roundeven(-3.1), -3.0);
        expect_exact(roundeven(3.5), 4.0);
        expect_exact(roundeven(-4.5), -4.0);
        
        expect_exact(nextup(-INFINITY), -DBL_MAX);
        expect_exact(nextup(-1.0-DBL_EPSILON), -1.0);
        expect_exact(nextup(-DBL_TRUE_MIN), -0.0);
        expect_exact(nextup(-0.0), DBL_TRUE_MIN);
        expect_exact(nextup(1.0), 1.0+DBL_EPSILON);
        expect_exact(nextup(DBL_MAX), +INFINITY);
        expect_exact(nextup(+INFINITY), +INFINITY);
        expect_exact(nextupl(-INFINITY), -LDBL_MAX);
        expect_exact(nextupl(-1.0-LDBL_EPSILON), -1.0);
        expect_exact(nextupl(-LDBL_TRUE_MIN), -0.0);
        expect_exact(nextupl(-0.0), LDBL_TRUE_MIN);
        expect_exact(nextupl(1.0), 1.0+LDBL_EPSILON);
        expect_exact(nextupl(LDBL_MAX), +INFINITY);
        expect_exact(nextupl(+INFINITY), +INFINITY);
        expect_exact(nextupf(-INFINITY), -FLT_MAX);
        expect_exact(nextupf(-1.0-FLT_EPSILON), -1.0);
        expect_exact(nextupf(-FLT_TRUE_MIN), -0.0);
        expect_exact(nextupf(-0.0), FLT_TRUE_MIN);
        expect_exact(nextupf(1.0), 1.0+FLT_EPSILON);
        expect_exact(nextupf(FLT_MAX), +INFINITY);
        expect_exact(nextupf(+INFINITY), +INFINITY);

        expect_exact(nextdown(-INFINITY), -INFINITY);
        expect_exact(nextdown(-DBL_MAX), -INFINITY);
        expect_exact(nextdown(-1.0), -1.0-DBL_EPSILON);
        expect_exact(nextdown(0.0), -DBL_TRUE_MIN);
        expect_exact(nextdown(1.0+DBL_EPSILON), 1.0);
        expect_exact(nextdown(+INFINITY), DBL_MAX);
        expect_exact(nextdownl(-INFINITY), -INFINITY);
        expect_exact(nextdownl(-LDBL_MAX), -INFINITY);
        expect_exact(nextdownl(-1.0), -1.0-LDBL_EPSILON);
        expect_exact(nextdownl(0.0), -LDBL_TRUE_MIN);
        expect_exact(nextdownl(1.0+LDBL_EPSILON), 1.0);
        expect_exact(nextdownl(+INFINITY), LDBL_MAX);
        expect_exact(nextdownf(-INFINITY), -INFINITY);
        expect_exact(nextdownf(-FLT_MAX), -INFINITY);
        expect_exact(nextdownf(-1.0), -1.0-FLT_EPSILON);
        expect_exact(nextdownf(0.0), -FLT_TRUE_MIN);
        expect_exact(nextdownf(1.0+FLT_EPSILON), 1.0);
        expect_exact(nextdownf(+INFINITY), FLT_MAX);

        d = 123.25;
        expect_exact(canonicalize(&d2,&d), 0);
        expect_exact(d2, 123.25);
        d = -INFINITY;
        expect_exact(canonicalize(&d2,&d), 0);
        expect_exact(d2, -INFINITY);
        d = NAN;
        expect_exact(canonicalize(&d2,&d), 0);
        expect_nan(d2);

        f = 123.25;
        expect_exact(canonicalizef(&f2,&f), 0);
        expect_exact(f2, 123.25);
        f = -INFINITY;
        expect_exact(canonicalizef(&f2,&f), 0);
        expect_exact(f2, -INFINITY);
        f = NAN;
        expect_exact(canonicalizef(&f2,&f), 0);
        expect_nan(f2);

        ld = 123.25;
        expect_exact(canonicalizel(&ld2,&ld), 0);
        expect_exact(ld2, 123.25);
        ld = -INFINITY;
        expect_exact(canonicalizel(&ld2,&ld), 0);
        expect_exact(ld2, -INFINITY);
        ld = NAN;
        expect_exact(canonicalizel(&ld2,&ld), 0);
        expect_nan(ld2);

        expect_exact(fadd(0x0.8000017ffffff8p0, 0x0.00000000000007p0),
                0x0.800001p0);
        expect_exact(faddl(0x0.8000017fffffffffp0L, 0x0.0000000000000000fp0L),
                0x0.800001p0);
        expect_exact(daddl(0x0.8000000000000bffp0L, 0x0.0000000000000000fp0L),
                0x0.80000000000008p0);

        expect_exact(fsub(0x0.8000017ffffff8p0, -0x0.00000000000007p0),
                0x0.800001p0);
        expect_exact(fsubl(0x0.8000017fffffffffp0L, -0x0.0000000000000000fp0L),
                0x0.800001p0);
        expect_exact(dsubl(0x0.8000000000000bffp0L, -0x0.0000000000000000fp0L),
                0x0.80000000000008p0);

        expect_exact(fmul(0x1.fffffdfffffbfp-2, 0x1.00000200041p-1),
                0x1.000002p-2);
        expect_exact(fmull(0x8.000010000020001p0L, 0xf.ffffefffffeffffp0L),
                0x1.000002p7);
        expect_exact(dmull(0x8.000000000000801p-3L, 0xf.ffffffffffff7ffp-4L),
                0x1.0000000000001p0);

        expect_exact(fdiv(0x1.fffffeffffffp-2, 0x1.000001000001p-1),
                0x1.fffffep-1);
        expect_exact(ddivl(0x8.0000000000018p-3L, 0xf.fffffffffffe8p-4L),
                0x1.0000000000005p0);

        expect_exact(fsqrt(0x1.0000020000011p0), 0x1.000002p0);
        expect_exact(dsqrtl(0x8.000000000000801p-3L), 0x1.0000000000001p0);

        printf ("Passed Conformance Test c23math\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23math\n");
}
