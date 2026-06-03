/****************************************************************
*
*  stdbit.h - bit and byte utilities
*
*  May 2026
*  Stephen Heumann
*
****************************************************************/

#ifndef __stdbit__
#define __stdbit__

#ifndef __size_t__
#define __size_t__ 1
typedef unsigned long size_t;
#endif

/* Exact-width integer types */
typedef signed char     int8_t;
typedef short           int16_t;
typedef long            int32_t;
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
typedef long long       int64_t;
#endif

typedef unsigned char   uint8_t;
typedef unsigned short  uint16_t;
typedef unsigned long   uint32_t;
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
typedef unsigned long long uint64_t;
#endif

/* Minimum-width integer types */
typedef signed char     int_least8_t;
typedef short           int_least16_t;
typedef long            int_least32_t;
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
typedef long long       int_least64_t;
#endif

typedef unsigned char   uint_least8_t;
typedef unsigned short  uint_least16_t;
typedef unsigned long   uint_least32_t;
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
typedef unsigned long long uint_least64_t;
#endif

#define __STDC_ENDIAN_LITTLE__ 0
#define __STDC_ENDIAN_BIG__ 1
#define __STDC_ENDIAN_NATIVE__ 0

unsigned int    stdc_leading_zeros_uc(unsigned char);
unsigned int    stdc_leading_zeros_us(unsigned short);
unsigned int    stdc_leading_zeros_ui(unsigned int);
unsigned int    stdc_leading_zeros_ul(unsigned long);
unsigned int    stdc_leading_zeros_ull(unsigned long long);
unsigned int    stdc_leading_ones_uc(unsigned char);
unsigned int    stdc_leading_ones_us(unsigned short);
unsigned int    stdc_leading_ones_ui(unsigned int);
unsigned int    stdc_leading_ones_ul(unsigned long);
unsigned int    stdc_leading_ones_ull(unsigned long long);
unsigned int    stdc_trailing_zeros_uc(unsigned char);
unsigned int    stdc_trailing_zeros_us(unsigned short);
unsigned int    stdc_trailing_zeros_ui(unsigned int);
unsigned int    stdc_trailing_zeros_ul(unsigned long);
unsigned int    stdc_trailing_zeros_ull(unsigned long long);
unsigned int    stdc_trailing_ones_uc(unsigned char);
unsigned int    stdc_trailing_ones_us(unsigned short);
unsigned int    stdc_trailing_ones_ui(unsigned int);
unsigned int    stdc_trailing_ones_ul(unsigned long);
unsigned int    stdc_trailing_ones_ull(unsigned long long);
unsigned int    stdc_first_leading_zero_uc(unsigned char);
unsigned int    stdc_first_leading_zero_us(unsigned short);
unsigned int    stdc_first_leading_zero_ui(unsigned int);
unsigned int    stdc_first_leading_zero_ul(unsigned long);
unsigned int    stdc_first_leading_zero_ull(unsigned long long);
unsigned int    stdc_first_leading_one_uc(unsigned char);
unsigned int    stdc_first_leading_one_us(unsigned short);
unsigned int    stdc_first_leading_one_ui(unsigned int);
unsigned int    stdc_first_leading_one_ul(unsigned long);
unsigned int    stdc_first_leading_one_ull(unsigned long long);
unsigned int    stdc_first_trailing_zero_uc(unsigned char);
unsigned int    stdc_first_trailing_zero_us(unsigned short);
unsigned int    stdc_first_trailing_zero_ui(unsigned int);
unsigned int    stdc_first_trailing_zero_ul(unsigned long);
unsigned int    stdc_first_trailing_zero_ull(unsigned long long);
unsigned int    stdc_first_trailing_one_uc(unsigned char);
unsigned int    stdc_first_trailing_one_us(unsigned short);
unsigned int    stdc_first_trailing_one_ui(unsigned int);
unsigned int    stdc_first_trailing_one_ul(unsigned long);
unsigned int    stdc_first_trailing_one_ull(unsigned long long);
unsigned int    stdc_count_zeros_uc(unsigned char);
unsigned int    stdc_count_zeros_us(unsigned short);
unsigned int    stdc_count_zeros_ui(unsigned int);
unsigned int    stdc_count_zeros_ul(unsigned long);
unsigned int    stdc_count_zeros_ull(unsigned long long);
unsigned int    stdc_count_ones_uc(unsigned char);
unsigned int    stdc_count_ones_us(unsigned short);
unsigned int    stdc_count_ones_ui(unsigned int);
unsigned int    stdc_count_ones_ul(unsigned long);
unsigned int    stdc_count_ones_ull(unsigned long long);
_Bool           stdc_has_single_bit_uc(unsigned char);
_Bool           stdc_has_single_bit_us(unsigned short);
_Bool           stdc_has_single_bit_ui(unsigned int);
_Bool           stdc_has_single_bit_ul(unsigned long);
_Bool           stdc_has_single_bit_ull(unsigned long long);
unsigned int    stdc_bit_width_uc(unsigned char);
unsigned int    stdc_bit_width_us(unsigned short);
unsigned int    stdc_bit_width_ui(unsigned int);
unsigned int    stdc_bit_width_ul(unsigned long);
unsigned int    stdc_bit_width_ull(unsigned long long);
unsigned char   stdc_bit_floor_uc(unsigned char);
unsigned short  stdc_bit_floor_us(unsigned short);
unsigned int    stdc_bit_floor_ui(unsigned int);
unsigned long   stdc_bit_floor_ul(unsigned long);
unsigned long long stdc_bit_floor_ull(unsigned long long);
unsigned char   stdc_bit_ceil_uc(unsigned char);
unsigned short  stdc_bit_ceil_us(unsigned short);
unsigned int    stdc_bit_ceil_ui(unsigned int);
unsigned long   stdc_bit_ceil_ul(unsigned long);
unsigned long long stdc_bit_ceil_ull(unsigned long long);

#define __tg_bit_op(fn,x) _Generic((x), \
   unsigned char: fn##_uc, \
   unsigned short: fn##_us, \
   unsigned int: fn##_ui, \
   unsigned long: fn##_ul, \
   unsigned long long: fn##_ull, \
   unsigned _BitInt(8): fn##_uc, \
   unsigned _BitInt(16): fn##_us, \
   unsigned _BitInt(32): fn##_ul, \
   unsigned _BitInt(64): fn##_ull)(x)

#define __tg_bit_op_return_arg_type(fn,x) _Generic((x), \
   unsigned _BitInt(8): (unsigned _BitInt(8))__tg_bit_op(fn,x), \
   unsigned _BitInt(16): (unsigned _BitInt(16))__tg_bit_op(fn,x), \
   unsigned _BitInt(32): (unsigned _BitInt(32))__tg_bit_op(fn,x), \
   unsigned _BitInt(64): (unsigned _BitInt(64))__tg_bit_op(fn,x), \
   default: __tg_bit_op(fn,x))

#define stdc_leading_zeros(x) __tg_bit_op(stdc_leading_zeros,(x))
#define stdc_leading_ones(x) __tg_bit_op(stdc_leading_ones,(x))
#define stdc_trailing_zeros(x) __tg_bit_op(stdc_trailing_zeros,(x))
#define stdc_trailing_ones(x) __tg_bit_op(stdc_trailing_ones,(x))
#define stdc_first_leading_zero(x) __tg_bit_op(stdc_first_leading_zero,(x))
#define stdc_first_leading_one(x) __tg_bit_op(stdc_first_leading_one,(x))
#define stdc_first_trailing_zero(x) __tg_bit_op(stdc_first_trailing_zero,(x))
#define stdc_first_trailing_one(x) __tg_bit_op(stdc_first_trailing_one,(x))
#define stdc_count_zeros(x) __tg_bit_op(stdc_count_zeros,(x))
#define stdc_count_ones(x) __tg_bit_op(stdc_count_ones,(x))
#define stdc_has_single_bit(x) __tg_bit_op(stdc_has_single_bit,(x))
#define stdc_bit_width(x) __tg_bit_op(stdc_bit_width,(x))
#define stdc_bit_floor(x) __tg_bit_op_return_arg_type(stdc_bit_floor,(x))
#define stdc_bit_ceil(x) __tg_bit_op_return_arg_type(stdc_bit_ceil,(x))

#endif
