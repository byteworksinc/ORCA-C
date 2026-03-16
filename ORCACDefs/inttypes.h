/****************************************************************
*
*  inttypes.h - format conversion of integer types
*
*  September 2017
*  Stephen Heumann
*
****************************************************************/

#ifndef __inttypes__
#define __inttypes__

#include <stdint.h>

/* fprintf macros for signed integers */

#define PRId8           "d"     /* int8_t */
#define PRId16          "d"     /* int16_t */
#define PRId32          "ld"    /* int32_t */
#define PRId64          "lld"   /* int64_t */
#define PRIdLEAST8      "d"     /* int_least8_t */
#define PRIdLEAST16     "d"     /* int_least16_t */
#define PRIdLEAST32     "ld"    /* int_least32_t */
#define PRIdLEAST64     "lld"   /* int_least64_t */
#define PRIdFAST8       "d"     /* int_fast8_t */
#define PRIdFAST16      "d"     /* int_fast16_t */
#define PRIdFAST32      "ld"    /* int_fast32_t */
#define PRIdFAST64      "lld"   /* int_fast64_t */
#define PRIdMAX         "jd"    /* intmax_t */
#define PRIdPTR         "ld"    /* intptr_t */

#define PRIi8           "i"     /* int8_t */
#define PRIi16          "i"     /* int16_t */
#define PRIi32          "li"    /* int32_t */
#define PRIi64          "lli"   /* int64_t */
#define PRIiLEAST8      "i"     /* int_least8_t */
#define PRIiLEAST16     "i"     /* int_least16_t */
#define PRIiLEAST32     "li"    /* int_least32_t */
#define PRIiLEAST64     "lli"   /* int_least64_t */
#define PRIiFAST8       "i"     /* int_fast8_t */
#define PRIiFAST16      "i"     /* int_fast16_t */
#define PRIiFAST32      "li"    /* int_fast32_t */
#define PRIiFAST64      "lli"   /* int_fast64_t */
#define PRIiMAX         "ji"    /* intmax_t */
#define PRIiPTR         "li"    /* intptr_t */

/* fprintf macros for unsigned integers */

#define PRIo8           "o"     /* uint8_t */
#define PRIo16          "o"     /* uint16_t */
#define PRIo32          "lo"    /* uint32_t */
#define PRIo64          "llo"   /* uint64_t */
#define PRIoLEAST8      "o"     /* uint_least8_t */
#define PRIoLEAST16     "o"     /* uint_least16_t */
#define PRIoLEAST32     "lo"    /* uint_least32_t */
#define PRIoLEAST64     "llo"   /* uint_least64_t */
#define PRIoFAST8       "o"     /* uint_fast8_t */
#define PRIoFAST16      "o"     /* uint_fast16_t */
#define PRIoFAST32      "lo"    /* uint_fast32_t */
#define PRIoFAST64      "llo"   /* uint_fast64_t */
#define PRIoMAX         "jo"    /* uintmax_t */
#define PRIoPTR         "lo"    /* uintptr_t */

#define PRIu8           "u"     /* uint8_t */
#define PRIu16          "u"     /* uint16_t */
#define PRIu32          "lu"    /* uint32_t */
#define PRIu64          "llu"   /* uint64_t */
#define PRIuLEAST8      "u"     /* uint_least8_t */
#define PRIuLEAST16     "u"     /* uint_least16_t */
#define PRIuLEAST32     "lu"    /* uint_least32_t */
#define PRIuLEAST64     "llu"   /* uint_least64_t */
#define PRIuFAST8       "u"     /* uint_fast8_t */
#define PRIuFAST16      "u"     /* uint_fast16_t */
#define PRIuFAST32      "lu"    /* uint_fast32_t */
#define PRIuFAST64      "llu"   /* uint_fast64_t */
#define PRIuMAX         "ju"    /* uintmax_t */
#define PRIuPTR         "lu"    /* uintptr_t */

#define PRIx8           "x"     /* uint8_t */
#define PRIx16          "x"     /* uint16_t */
#define PRIx32          "lx"    /* uint32_t */
#define PRIx64          "llx"   /* uint64_t */
#define PRIxLEAST8      "x"     /* uint_least8_t */
#define PRIxLEAST16     "x"     /* uint_least16_t */
#define PRIxLEAST32     "lx"    /* uint_least32_t */
#define PRIxLEAST64     "llx"   /* uint_least64_t */
#define PRIxFAST8       "x"     /* uint_fast8_t */
#define PRIxFAST16      "x"     /* uint_fast16_t */
#define PRIxFAST32      "lx"    /* uint_fast32_t */
#define PRIxFAST64      "llx"   /* uint_fast64_t */
#define PRIxMAX         "jx"    /* uintmax_t */
#define PRIxPTR         "lx"    /* uintptr_t */

#define PRIX8           "X"     /* uint8_t */
#define PRIX16          "X"     /* uint16_t */
#define PRIX32          "lX"    /* uint32_t */
#define PRIX64          "llX"   /* uint64_t */
#define PRIXLEAST8      "X"     /* uint_least8_t */
#define PRIXLEAST16     "X"     /* uint_least16_t */
#define PRIXLEAST32     "lX"    /* uint_least32_t */
#define PRIXLEAST64     "llX"   /* uint_least64_t */
#define PRIXFAST8       "X"     /* uint_fast8_t */
#define PRIXFAST16      "X"     /* uint_fast16_t */
#define PRIXFAST32      "lX"    /* uint_fast32_t */
#define PRIXFAST64      "llX"   /* uint_fast64_t */
#define PRIXMAX         "jX"    /* uintmax_t */
#define PRIXPTR         "lX"    /* uintptr_t */

#if __STDC_VERSION__ >= 202311L
#define PRIb8           "hhb"   /* uint8_t */
#define PRIb16          "b"     /* uint16_t */
#define PRIb32          "lb"    /* uint32_t */
#define PRIb64          "llb"   /* uint64_t */
#define PRIbLEAST8      "hhb"   /* uint_least8_t */
#define PRIbLEAST16     "b"     /* uint_least16_t */
#define PRIbLEAST32     "lb"    /* uint_least32_t */
#define PRIbLEAST64     "llb"   /* uint_least64_t */
#define PRIbFAST8       "b"     /* uint_fast8_t */
#define PRIbFAST16      "b"     /* uint_fast16_t */
#define PRIbFAST32      "lb"    /* uint_fast32_t */
#define PRIbFAST64      "llb"   /* uint_fast64_t */
#define PRIbMAX         "jb"    /* uintmax_t */
#define PRIbPTR         "lb"    /* uintptr_t */
#endif

#if !defined(__KeepNamespacePure__) || __STDC_VERSION__ >= 202311L
#define PRIB8           "hhB"   /* uint8_t */
#define PRIB16          "B"     /* uint16_t */
#define PRIB32          "lB"    /* uint32_t */
#define PRIB64          "llB"   /* uint64_t */
#define PRIBLEAST8      "hhB"   /* uint_least8_t */
#define PRIBLEAST16     "B"     /* uint_least16_t */
#define PRIBLEAST32     "lB"    /* uint_least32_t */
#define PRIBLEAST64     "llB"   /* uint_least64_t */
#define PRIBFAST8       "B"     /* uint_fast8_t */
#define PRIBFAST16      "B"     /* uint_fast16_t */
#define PRIBFAST32      "lB"    /* uint_fast32_t */
#define PRIBFAST64      "llB"   /* uint_fast64_t */
#define PRIBMAX         "jB"    /* uintmax_t */
#define PRIBPTR         "lB"    /* uintptr_t */
#endif

/* fscanf macros for signed integers */

#define SCNd8           "hhd"   /* int8_t */
#define SCNd16          "hd"    /* int16_t */
#define SCNd32          "ld"    /* int32_t */
#define SCNd64          "lld"   /* int64_t */
#define SCNdLEAST8      "hhd"   /* int_least8_t */
#define SCNdLEAST16     "hd"    /* int_least16_t */
#define SCNdLEAST32     "ld"    /* int_least32_t */
#define SCNdLEAST64     "lld"   /* int_least64_t */
#define SCNdFAST8       "hd"    /* int_fast8_t */
#define SCNdFAST16      "hd"    /* int_fast16_t */
#define SCNdFAST32      "ld"    /* int_fast32_t */
#define SCNdFAST64      "lld"   /* int_fast64_t */
#define SCNdMAX         "jd"    /* intmax_t */
#define SCNdPTR         "ld"    /* intptr_t */

#define SCNi8           "hhi"   /* int8_t */
#define SCNi16          "hi"    /* int16_t */
#define SCNi32          "li"    /* int32_t */
#define SCNi64          "lli"   /* int64_t */
#define SCNiLEAST8      "hhi"   /* int_least8_t */
#define SCNiLEAST16     "hi"    /* int_least16_t */
#define SCNiLEAST32     "li"    /* int_least32_t */
#define SCNiLEAST64     "lli"   /* int_least64_t */
#define SCNiFAST8       "hi"    /* int_fast8_t */
#define SCNiFAST16      "hi"    /* int_fast16_t */
#define SCNiFAST32      "li"    /* int_fast32_t */
#define SCNiFAST64      "lli"   /* int_fast64_t */
#define SCNiMAX         "ji"    /* intmax_t */
#define SCNiPTR         "li"    /* intptr_t */

/* fscanf macros for unsigned integers */

#define SCNo8           "hho"   /* uint8_t */
#define SCNo16          "ho"    /* uint16_t */
#define SCNo32          "lo"    /* uint32_t */
#define SCNo64          "llo"   /* uint64_t */
#define SCNoLEAST8      "hho"   /* uint_least8_t */
#define SCNoLEAST16     "ho"    /* uint_least16_t */
#define SCNoLEAST32     "lo"    /* uint_least32_t */
#define SCNoLEAST64     "llo"   /* uint_least64_t */
#define SCNoFAST8       "ho"    /* uint_fast8_t */
#define SCNoFAST16      "ho"    /* uint_fast16_t */
#define SCNoFAST32      "lo"    /* uint_fast32_t */
#define SCNoFAST64      "llo"   /* uint_fast64_t */
#define SCNoMAX         "jo"    /* uintmax_t */
#define SCNoPTR         "lo"    /* uintptr_t */

#define SCNu8           "hhu"   /* uint8_t */
#define SCNu16          "hu"    /* uint16_t */
#define SCNu32          "lu"    /* uint32_t */
#define SCNu64          "llu"   /* uint64_t */
#define SCNuLEAST8      "hhu"   /* uint_least8_t */
#define SCNuLEAST16     "hu"    /* uint_least16_t */
#define SCNuLEAST32     "lu"    /* uint_least32_t */
#define SCNuLEAST64     "llu"   /* uint_least64_t */
#define SCNuFAST8       "hu"    /* uint_fast8_t */
#define SCNuFAST16      "hu"    /* uint_fast16_t */
#define SCNuFAST32      "lu"    /* uint_fast32_t */
#define SCNuFAST64      "llu"   /* uint_fast64_t */
#define SCNuMAX         "ju"    /* uintmax_t */
#define SCNuPTR         "lu"    /* uintptr_t */

#define SCNx8           "hhx"   /* uint8_t */
#define SCNx16          "hx"    /* uint16_t */
#define SCNx32          "lx"    /* uint32_t */
#define SCNx64          "llx"   /* uint64_t */
#define SCNxLEAST8      "hhx"   /* uint_least8_t */
#define SCNxLEAST16     "hx"    /* uint_least16_t */
#define SCNxLEAST32     "lx"    /* uint_least32_t */
#define SCNxLEAST64     "llx"   /* uint_least64_t */
#define SCNxFAST8       "hx"    /* uint_fast8_t */
#define SCNxFAST16      "hx"    /* uint_fast16_t */
#define SCNxFAST32      "lx"    /* uint_fast32_t */
#define SCNxFAST64      "llx"   /* uint_fast64_t */
#define SCNxMAX         "jx"    /* uintmax_t */
#define SCNxPTR         "lx"    /* uintptr_t */

#if __STDC_VERSION__ >= 202311L
#define SCNb8           "hhb"   /* uint8_t */
#define SCNb16          "hb"    /* uint16_t */
#define SCNb32          "lb"    /* uint32_t */
#define SCNb64          "llb"   /* uint64_t */
#define SCNbLEAST8      "hhb"   /* uint_least8_t */
#define SCNbLEAST16     "hb"    /* uint_least16_t */
#define SCNbLEAST32     "lb"    /* uint_least32_t */
#define SCNbLEAST64     "llb"   /* uint_least64_t */
#define SCNbFAST8       "hb"    /* uint_fast8_t */
#define SCNbFAST16      "hb"    /* uint_fast16_t */
#define SCNbFAST32      "lb"    /* uint_fast32_t */
#define SCNbFAST64      "llb"   /* uint_fast64_t */
#define SCNbMAX         "jb"    /* uintmax_t */
#define SCNbPTR         "lb"    /* uintptr_t */
#endif

#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
typedef struct {intmax_t quot,rem;} imaxdiv_t;

intmax_t  imaxabs(intmax_t);
imaxdiv_t imaxdiv(intmax_t, intmax_t);
intmax_t  strtoimax(const char * restrict, char ** restrict, int);
uintmax_t strtoumax(const char * restrict, char ** restrict, int);
#endif

/*
 * The C99 and C11 standards require the following functions
 * to be declared here, but they are not currently supported.
 * 
 * intmax_t  wcstoimax(const wchar_t * restrict, wchar_t ** restrict, int);
 * uintmax_t wcstoumax(const wchar_t * restrict, wchar_t ** restrict, int);
 */

#endif
