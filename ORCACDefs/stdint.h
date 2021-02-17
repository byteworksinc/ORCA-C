/****************************************************************
*
*  stdint.h - integer types
*
*  September 2017
*  Stephen Heumann
*
****************************************************************/

#ifndef __stdint__
#define __stdint__

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

/* Fastest minimum-width integer types */
typedef short           int_fast8_t;    /* Note: 16-bit type */
typedef short           int_fast16_t;
typedef long            int_fast32_t;
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
typedef long long       int_fast64_t;
#endif

typedef unsigned short  uint_fast8_t;   /* Note: 16-bit type */
typedef unsigned short  uint_fast16_t;
typedef unsigned long   uint_fast32_t;
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
typedef unsigned long long uint_fast64_t;
#endif

/* Integer types capable of holding object pointers */
typedef long            intptr_t;
typedef unsigned long   uintptr_t;

/* Greatest-width integer types */
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
typedef long long          intmax_t;
typedef unsigned long long uintmax_t;
#endif

/* Limits of exact-width integer types */
#define INT8_MIN        (-128)
#define INT16_MIN       (-32767-1)
#define INT32_MIN       (-2147483647-1)
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define INT64_MIN       (-9223372036854775807-1)
#endif

#define INT8_MAX        127
#define INT16_MAX       32767
#define INT32_MAX       2147483647
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define INT64_MAX       9223372036854775807
#endif

#define UINT8_MAX       255
#define UINT16_MAX      65535u
#define UINT32_MAX      4294967295u
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define UINT64_MAX      18446744073709551615u
#endif

/* Limits of minimum-width integer types */
#define INT_LEAST8_MIN  (-128)
#define INT_LEAST16_MIN (-32767-1)
#define INT_LEAST32_MIN (-2147483647-1)
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define INT_LEAST64_MIN (-9223372036854775807-1)
#endif

#define INT_LEAST8_MAX  127
#define INT_LEAST16_MAX 32767
#define INT_LEAST32_MAX 2147483647
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define INT_LEAST64_MAX 9223372036854775807
#endif

#define UINT_LEAST8_MAX  255
#define UINT_LEAST16_MAX 65535u
#define UINT_LEAST32_MAX 4294967295u
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define UINT_LEAST64_MAX 18446744073709551615u
#endif

/* Limits of fastest minimum-width integer types */
#define INT_FAST8_MIN   (-32767-1)
#define INT_FAST16_MIN  (-32767-1)
#define INT_FAST32_MIN  (-2147483647-1)
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define INT_FAST64_MIN  (-9223372036854775807-1)
#endif

#define INT_FAST8_MAX   32767
#define INT_FAST16_MAX  32767
#define INT_FAST32_MAX  2147483647
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define INT_FAST64_MAX  9223372036854775807
#endif

#define UINT_FAST8_MAX  65535u
#define UINT_FAST16_MAX 65535u
#define UINT_FAST32_MAX 4294967295u
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define UINT_FAST64_MAX 18446744073709551615u
#endif

/* Limits of integer types capable of holding object pointers */
#define INTPTR_MIN      (-2147483647-1)
#define INTPTR_MAX      2147483647
#define UINTPTR_MAX     4294967295u

/* Limits of greatest-width integer types */
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define INTMAX_MIN      (-9223372036854775807-1)
#define INTMAX_MAX      9223372036854775807
#define UINTMAX_MAX     18446744073709551615u
#endif

/* Limits of other integer types */
#define PTRDIFF_MIN     (-2147483647-1)
#define PTRDIFF_MAX     2147483647

#define SIG_ATOMIC_MIN  (-32767-1)
#define SIG_ATOMIC_MAX  32767

#define SIZE_MAX        4294967295u

#ifndef WCHAR_MIN
#define WCHAR_MIN       0u
#endif
#ifndef WCHAR_MAX
#define WCHAR_MAX       65535u
#endif

/* WINT_MIN and WINT_MAX are not defined because wint_t is not defined. */

/* Macros for minimum-width integer constants */
#define INT8_C(val)     (val)
#define INT16_C(val)    (val)
#define INT32_C(val)    (val ## L)
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define INT64_C(val)    (val ## LL)
#endif

#define UINT8_C(val)    (val)
#define UINT16_C(val)   (val ## U)
#define UINT32_C(val)   (val ## UL)
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define UINT64_C(val)   (val ## ULL)
#endif

/* Macros for greatest-width integer constants */
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define INTMAX_C(val)   (val ## LL)
#define UINTMAX_C(val)  (val ## ULL)
#endif

#endif
