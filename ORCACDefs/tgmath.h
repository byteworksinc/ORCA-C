/****************************************************************
*
*  tgmath.h - type-generic math macros
*
*  November 2021
*  Stephen Heumann
*
****************************************************************/

#ifndef __tgmath__
#define __tgmath__

#include <math.h>

#define __tg_real_x(fn,x) _Generic((x), \
   float: fn##f, \
   long double: fn##l, \
   default: fn)(x)

#define __tg_real_x_other(fn,x,other) _Generic((x), \
   float: fn##f, \
   long double: fn##l, \
   default: fn)((x),(other))

#define __tg_real_x_y(fn,x,y) _Generic((x), \
   float: _Generic((y), float: fn##f, long double: fn##l, default: fn), \
   long double: fn##l, \
   default: _Generic((y), long double: fn##l, default: fn))((x),(y))

#define __tg_real_x_y_other(fn,x,y,other) _Generic((x), \
   float: _Generic((y), float: fn##f, long double: fn##l, default: fn), \
   long double: fn##l, \
   default: _Generic((y), long double: fn##l, default: fn))((x),(y),(other))

#define __tg_real_x_y_z(fn,x,y,z) _Generic((x), \
   float: _Generic((y), \
      float: _Generic((z), float: fn##f, long double: fn##l, default: fn), \
      long double: fn##l, \
      default: _Generic((z), long double: fn##l, default: fn)), \
   long double: fn##l, \
   default: _Generic((y), \
      long double: fn##l, \
      default: _Generic((z), long double: fn##l, default: fn)))((x),(y),(z))

#define __tg_x(fn,x) __tg_real_x(fn,(x))
#define __tg_x_y(fn,x,y) __tg_real_x_y(fn,(x),(y))

#define acos(x)         __tg_x(acos,(x))
#define acosh(x)        __tg_x(acosh,(x))
#define asin(x)         __tg_x(asin,(x))
#define asinh(x)        __tg_x(asinh,(x))
#define atan(x)         __tg_x(atan,(x))
#define atanh(x)        __tg_x(atanh,(x))
#define atan2(y,x)      __tg_real_x_y(atan2,(y),(x))
#define cbrt(x)         __tg_real_x(cbrt,(x))
#define ceil(x)         __tg_real_x(ceil,(x))
#define cos(x)          __tg_x(cos,(x))
#define cosh(x)         __tg_x(cosh,(x))
#define copysign(x,y)   __tg_real_x_y(copysign,(x),(y))
#define erf(x)          __tg_real_x(erf,(x))
#define erfc(x)         __tg_real_x(erfc,(x))
#define exp(x)          __tg_x(exp,(x))
#define exp2(x)         __tg_real_x(exp2,(x))
#define expm1(x)        __tg_real_x(expm1,(x))
#define fabs(x)         __tg_real_x(fabs,(x))
#define fdim(x,y)       __tg_real_x_y(fdim,(x),(y))
#define fma(x,y,z)      __tg_real_x_y_z(fma,(x),(y),(z))
#define fmax(x,y)       __tg_real_x_y(fmax,(x),(y))
#define fmin(x,y)       __tg_real_x_y(fmin,(x),(y))
#define floor(x)        __tg_real_x(floor,(x))
#define fmod(x,y)       __tg_real_x_y(fmod,(x),(y))
#define frexp(x,nptr)   __tg_real_x_other(frexp,(x),(nptr))
#define hypot(x,y)      __tg_real_x_y(hypot,(x),(y))
#define ilogb(x)        __tg_real_x(ilogb,(x))
#define ldexp(x,n)      __tg_real_x_other(ldexp,(x),(n))
#define llrint(x)       __tg_real_x(llrint,(x))
#define llround(x)      __tg_real_x(llround,(x))
#define log(x)          __tg_x(log,(x))
#define log10(x)        __tg_real_x(log10,(x))
#define log1p(x)        __tg_real_x(log1p,(x))
#define log2(x)         __tg_real_x(log2,(x))
#define logb(x)         __tg_real_x(logb,(x))
#define lrint(x)        __tg_real_x(lrint,(x))
#define lround(x)       __tg_real_x(lround,(x))
#define nearbyint(x)    __tg_real_x(nearbyint,(x))
#define nextafter(x,y)  __tg_real_x_y(nextafter,(x),(y))
#define nexttoward(x,y) __tg_real_x_y(nexttoward,(x),(y))
#define pow(x,y)        __tg_x_y(pow,(x),(y))
#define remainder(x,y)  __tg_real_x_y(remainder,(x),(y))
#define remquo(x,y,quo) __tg_real_x_y_other(remquo,(x),(y),(quo))
#define rint(x)         __tg_real_x(rint,(x))
#define round(x)        __tg_real_x(round,(x))
#define scalbn(x,n)     __tg_real_x_other(scalbn,(x),(n))
#define scalbln(x,n)    __tg_real_x_other(scalbln,(x),(n))
#define sin(x)          __tg_x(sin,(x))
#define sinh(x)         __tg_x(sinh,(x))
#define sqrt(x)         __tg_x(sqrt,(x))
#define tan(x)          __tg_x(tan,(x))
#define tanh(x)         __tg_x(tanh,(x))
#define tgamma(x)       __tg_real_x(tgamma,(x))
#define trunc(x)        __tg_real_x(trunc,(x))

#endif
