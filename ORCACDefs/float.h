/****************************************************************
*
*  float.h - limits on the size of real numbers
*
*  October 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#ifndef __float__
#define __float__

int __get_flt_rounds(void);
#define FLT_ROUNDS      (__get_flt_rounds())

#define FLT_EVAL_METHOD 2

#define FLT_HAS_SUBNORM 1
#define DBL_HAS_SUBNORM 1
#define LDBL_HAS_SUBNORM 1

#define FLT_RADIX       2

#define FLT_MANT_DIG    24
#define DBL_MANT_DIG    53
#define LDBL_MANT_DIG   64

#define FLT_DECIMAL_DIG 9
#define DBL_DECIMAL_DIG 17
#define LDBL_DECIMAL_DIG 21

#define DECIMAL_DIG     21

#define FLT_DIG         6
#define DBL_DIG         15
#define LDBL_DIG        18

#define FLT_MIN_EXP     (-125)
#define DBL_MIN_EXP     (-1021)
#define LDBL_MIN_EXP    (-16382)

#define FLT_MIN_10_EXP  (-37)
#define DBL_MIN_10_EXP  (-307)
#define LDBL_MIN_10_EXP (-4931)

#define FLT_MAX_EXP     128
#define DBL_MAX_EXP     1024
#define LDBL_MAX_EXP    16384

#define FLT_MAX_10_EXP  38
#define DBL_MAX_10_EXP  308
#define LDBL_MAX_10_EXP 4932

#define FLT_MAX         3.4028234663852885981E+38F
#define DBL_MAX         1.7976931348623157081E+308
#define LDBL_MAX        1.189731495357231765E+4932L

#define FLT_EPSILON     1.1920928955078125E-07F
#define DBL_EPSILON     2.2204460492503130808E-16
#define LDBL_EPSILON    1.084202172485504434007E-19L

#define FLT_MIN         1.175494350822287508E-38F
#define DBL_MIN         2.2250738585072013831E-308
#define LDBL_MIN        1.6810515715560467531E-4932L

#define FLT_TRUE_MIN    1.401298464324817070924E-45F
#define DBL_TRUE_MIN    4.940656458412465441766E-324
#define LDBL_TRUE_MIN   1.822599765941237E-4951L

#endif
