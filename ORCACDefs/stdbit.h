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

#endif
