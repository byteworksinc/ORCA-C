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

/*
 * Note: This header currently contains only some of the macros specified
 * in the C99 and later standards.  Others are not present because the
 * corresponding functions either are not available at all or have only
 * an unsuffixed version available.
 */

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

#define cbrt(x)         __tg_real_x(cbrt,(x))
#define copysign(x,y)   __tg_real_x_y(copysign,(x),(y))
#define exp2(x)         __tg_real_x(exp2,(x))
#define expm1(x)        __tg_real_x(expm1,(x))
#define ilogb(x)        __tg_real_x(ilogb,(x))
#define log1p(x)        __tg_real_x(log1p,(x))
#define log2(x)         __tg_real_x(log2,(x))
#define logb(x)         __tg_real_x(logb,(x))
#define lrint(x)        __tg_real_x(lrint,(x))
#define remainder(x,y)  __tg_real_x_y(remainder,(x),(y))
#define remquo(x,y,quo) __tg_real_x_y_other(remquo,(x),(y),(quo))
#define rint(x)         __tg_real_x(rint,(x))
#define scalbn(x,n)     __tg_real_x_other(scalbn,(x),(n))
#define trunc(x)        __tg_real_x(trunc,(x))

#endif
