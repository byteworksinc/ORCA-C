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

#define fpclassify(x) _Generic((x), \
   float: __fpclassifyf, \
   double: __fpclassifyd, \
   long double: __fpclassifyl)(x)

#define isfinite(x) (((fpclassify(x) + 1) & 0xF0) == 0)
#define isinf(x)    (fpclassify(x) == FP_INFINITE)
#define isnan(x)    (fpclassify((long double)(x)) == FP_NAN)
#define isnormal(x) (fpclassify(x) == FP_NORMAL)
#define signbit(x)  __signbit(x)

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
double          asin(double);
double          atan(double);
double          cos(double);
double          cosh(double);
double          exp(double);
double          log(double);
double          log10(double);
double          sin(double);
double          sinh(double);
double          sqrt(double);
double          tan(double);
double          tanh(double);
double          atan2(double, double);
double          ceil(double);
double          fabs(double);
double          floor(double);
double          fmod(double, double);
double          frexp(double, int *);
double          ldexp(double, int);
double          modf(double, double *);
double          pow(double, double);

#endif
