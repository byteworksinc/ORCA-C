/****************************************************************
*
*  math.h - math library
*
*  February 1989
*  Mike Westerfield
*
*  Copyright 1989, 1992
*  Byte Works, Inc.
*
****************************************************************/

#ifndef __math__
#define __math__

typedef long double float_t;
typedef long double double_t;

#define HUGE_VAL 1e5000
#define HUGE_VALF 1e5000F
#define HUGE_VALL 1e5000L

#define INFINITY 1e5000F

#define NAN (0.0F/0.0F)

#define FP_ILOGB0   (-32767-1)
#define FP_ILOGBNAN (-32767-1)

#define MATH_ERRNO       1
#define MATH_ERREXCEPT   2
#define math_errhandling 2

#define FP_INFINITE  0xFE
#define FP_NAN       0xFD
#define FP_NORMAL    0x00
#define FP_SUBNORMAL 0x01
#define FP_ZERO      0xFF

int __fpclassifyf(float);
int __fpclassifyd(double);
int __fpclassifyl(long double);
int __signbit(long double);
int __fpcompare(long double, long double, short);

#define __fpclassify(x) _Generic((x), \
   float: __fpclassifyf, \
   double: __fpclassifyd, \
   long double: __fpclassifyl)(x)

#define fpclassify(x) __fpclassify(x)
#define isfinite(x)  (((__fpclassify(x) + 1) & 0xF0) == 0)
#define isinf(x)     (__fpclassify(x) == FP_INFINITE)
#define isnan(x)     (__fpclassify((long double)(x)) == FP_NAN)
#define isnormal(x)  (__fpclassify(x) == FP_NORMAL)
#define signbit(x)   __signbit(x)

#define isgreater(x,y)      __fpcompare((x),(y),0x40)
#define isgreaterequal(x,y) __fpcompare((x),(y),0x42)
#define isless(x,y)         __fpcompare((x),(y),0x80)
#define islessequal(x,y)    __fpcompare((x),(y),0x82)
#define islessgreater(x,y)  __fpcompare((x),(y),0xC0)
#define isunordered(x,y)    __fpcompare((x),(y),0x01)

#ifndef __KeepNamespacePure__
   #define arctan(x) atan(x)
#endif

double          acos(double);
float           acosf(float);
long double     acosl(long double);
double          acosh(double);
float           acoshf(float);
long double     acoshl(long double);
double          asin(double);
float           asinf(float);
long double     asinl(long double);
double          asinh(double);
float           asinhf(float);
long double     asinhl(long double);
double          atan(double);
float           atanf(float);
long double     atanl(long double);
double          atanh(double);
float           atanhf(float);
long double     atanhl(long double);
double          atan2(double, double);
float           atan2f(float, float);
long double     atan2l(long double, long double);
double          cbrt(double);
float           cbrtf(float);
long double     cbrtl(long double);
double          ceil(double);
float           ceilf(float);
long double     ceill(long double);
double          copysign(double, double);
float           copysignf(float, float);
long double     copysignl(long double, long double);
double          cos(double);
float           cosf(float);
long double     cosl(long double);
double          cosh(double);
float           coshf(float);
long double     coshl(long double);
double          erf(double);
float           erff(float);
long double     erfl(long double);
double          erfc(double);
float           erfcf(float);
long double     erfcl(long double);
double          exp(double);
float           expf(float);
long double     expl(long double);
double          exp2(double);
float           exp2f(float);
long double     exp2l(long double);
double          expm1(double);
float           expm1f(float);
long double     expm1l(long double);
double          fabs(double);
float           fabsf(float);
long double     fabsl(long double);
double          fdim(double, double);
float           fdimf(float, float);
long double     fdiml(long double, long double);
double          floor(double);
float           floorf(float);
long double     floorl(long double);
double          fmax(double, double);
float           fmaxf(float, float);
long double     fmaxl(long double, long double);
double          fmin(double, double);
float           fminf(float, float);
long double     fminl(long double, long double);
double          fmod(double, double);
float           fmodf(float, float);
long double     fmodl(long double, long double);
double          frexp(double, int *);
float           frexpf(float, int *);
long double     frexpl(long double, int *);
double          hypot(double, double);
float           hypotf(float, float);
long double     hypotl(long double, long double);
int             ilogb(double);
int             ilogbf(float);
int             ilogbl(long double);
double          ldexp(double, int);
float           ldexpf(float, int);
long double     ldexpl(long double, int);
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
long long       llrint(double);
long long       llrintf(float);
long long       llrintl(long double);
long long       llround(double);
long long       llroundf(float);
long long       llroundl(long double);
#endif
double          log(double);
float           logf(float);
long double     logl(long double);
double          log10(double);
float           log10f(float);
long double     log10l(long double);
double          log1p(double);
float           log1pf(float);
long double     log1pl(long double);
double          log2(double);
float           log2f(float);
long double     log2l(long double);
double          logb(double);
float           logbf(float);
long double     logbl(long double);
long            lrint(double);
long            lrintf(float);
long            lrintl(long double);
long            lround(double);
long            lroundf(float);
long            lroundl(long double);
double          modf(double, double *);
float           modff(float, float *);
long double     modfl(long double, long double *);
double          nearbyint(double);
float           nearbyintf(float);
long double     nearbyintl(long double);
double          nan(const char *);
float           nanf(const char *);
long double     nanl(const char *);
double          nextafter(double, double);
float           nextafterf(float, float);
long double     nextafterl(long double, long double);
double          nexttoward(double, long double);
float           nexttowardf(float, long double);
long double     nexttowardl(long double, long double);
double          pow(double, double);
float           powf(float, float);
long double     powl(long double, long double);
double          remainder(double, double);
float           remainderf(float, float);
long double     remainderl(long double, long double);
double          remquo(double, double, int *);
float           remquof(float, float, int *);
long double     remquol(long double, long double, int *);
double          rint(double);
float           rintf(float);
long double     rintl(long double);
double          round(double);
float           roundf(float);
long double     roundl(long double);
double          scalbln(double, long);
float           scalblnf(float, long);
long double     scalblnl(long double, long);
double          scalbn(double, int);
float           scalbnf(float, int);
long double     scalbnl(long double, int);
double          sin(double);
float           sinf(float);
long double     sinl(long double);
double          sinh(double);
float           sinhf(float);
long double     sinhl(long double);
double          sqrt(double);
float           sqrtf(float);
long double     sqrtl(long double);
double          tan(double);
float           tanf(float);
long double     tanl(long double);
double          tanh(double);
float           tanhf(float);
long double     tanhl(long double);
double          trunc(double);
float           truncf(float);
long double     truncl(long double);

#endif
