/****************************************************************
*
*  inttypes.h - format conversion of integer types
*
*  September 2017
*  Stephen Heumann
*
****************************************************************/

/*
 * Note: The format specifier macros defined here generally comply with the
 * C99 and C11 standards, except that those associated with intmax_t and
 * uintmax_t correspond to their non-standard definitions as 32-bit types.
 * fscanf macros for 8-bit types are not defined because ORCA/C's fscanf
 * implementation currently does not support them.  The functions that the
 * standards specify should be declared in this header are also not available.
 */

#ifndef __inttypes__
#define __inttypes__

#include <stdint.h>

/* fprintf macros for signed integers */

#define PRId8           "d"     /* int8_t */
#define PRId16          "d"     /* int16_t */
#define PRId32          "ld"    /* int32_t */
#define PRIdLEAST8      "d"     /* int_least8_t */
#define PRIdLEAST16     "d"     /* int_least16_t */
#define PRIdLEAST32     "ld"    /* int_least32_t */
#define PRIdFAST8       "d"     /* int_fast8_t */
#define PRIdFAST16      "d"     /* int_fast16_t */
#define PRIdFAST32      "ld"    /* int_fast32_t */
#define PRIdMAX         "ld"    /* intmax_t */
#define PRIdPTR         "ld"    /* intptr_t */

#define PRIi8           "i"     /* int8_t */
#define PRIi16          "i"     /* int16_t */
#define PRIi32          "li"    /* int32_t */
#define PRIiLEAST8      "i"     /* int_least8_t */
#define PRIiLEAST16     "i"     /* int_least16_t */
#define PRIiLEAST32     "li"    /* int_least32_t */
#define PRIiFAST8       "i"     /* int_fast8_t */
#define PRIiFAST16      "i"     /* int_fast16_t */
#define PRIiFAST32      "li"    /* int_fast32_t */
#define PRIiMAX         "li"    /* intmax_t */
#define PRIiPTR         "li"    /* intptr_t */

/* fprintf macros for unsigned integers */

#define PRIo8           "o"     /* uint8_t */
#define PRIo16          "o"     /* uint16_t */
#define PRIo32          "lo"    /* uint32_t */
#define PRIoLEAST8      "o"     /* uint_least8_t */
#define PRIoLEAST16     "o"     /* uint_least16_t */
#define PRIoLEAST32     "lo"    /* uint_least32_t */
#define PRIoFAST8       "o"     /* uint_fast8_t */
#define PRIoFAST16      "o"     /* uint_fast16_t */
#define PRIoFAST32      "lo"    /* uint_fast32_t */
#define PRIoMAX         "lo"    /* uintmax_t */
#define PRIoPTR         "lo"    /* uintptr_t */

#define PRIu8           "u"     /* uint8_t */
#define PRIu16          "u"     /* uint16_t */
#define PRIu32          "lu"    /* uint32_t */
#define PRIuLEAST8      "u"     /* uint_least8_t */
#define PRIuLEAST16     "u"     /* uint_least16_t */
#define PRIuLEAST32     "lu"    /* uint_least32_t */
#define PRIuFAST8       "u"     /* uint_fast8_t */
#define PRIuFAST16      "u"     /* uint_fast16_t */
#define PRIuFAST32      "lu"    /* uint_fast32_t */
#define PRIuMAX         "lu"    /* uintmax_t */
#define PRIuPTR         "lu"    /* uintptr_t */

#define PRIx8           "x"     /* uint8_t */
#define PRIx16          "x"     /* uint16_t */
#define PRIx32          "lx"    /* uint32_t */
#define PRIxLEAST8      "x"     /* uint_least8_t */
#define PRIxLEAST16     "x"     /* uint_least16_t */
#define PRIxLEAST32     "lx"    /* uint_least32_t */
#define PRIxFAST8       "x"     /* uint_fast8_t */
#define PRIxFAST16      "x"     /* uint_fast16_t */
#define PRIxFAST32      "lx"    /* uint_fast32_t */
#define PRIxMAX         "lx"    /* uintmax_t */
#define PRIxPTR         "lx"    /* uintptr_t */

#define PRIX8           "X"     /* uint8_t */
#define PRIX16          "X"     /* uint16_t */
#define PRIX32          "lX"    /* uint32_t */
#define PRIXLEAST8      "X"     /* uint_least8_t */
#define PRIXLEAST16     "X"     /* uint_least16_t */
#define PRIXLEAST32     "lX"    /* uint_least32_t */
#define PRIXFAST8       "X"     /* uint_fast8_t */
#define PRIXFAST16      "X"     /* uint_fast16_t */
#define PRIXFAST32      "lX"    /* uint_fast32_t */
#define PRIXMAX         "lX"    /* uintmax_t */
#define PRIXPTR         "lX"    /* uintptr_t */

/* fscanf macros for signed integers */

#define SCNd16          "hd"    /* int16_t */
#define SCNd32          "ld"    /* int32_t */
#define SCNdLEAST16     "hd"    /* int_least16_t */
#define SCNdLEAST32     "ld"    /* int_least32_t */
#define SCNdFAST8       "hd"    /* int_fast8_t */
#define SCNdFAST16      "hd"    /* int_fast16_t */
#define SCNdFAST32      "ld"    /* int_fast32_t */
#define SCNdMAX         "ld"    /* intmax_t */
#define SCNdPTR         "ld"    /* intptr_t */

#define SCNi16          "hi"    /* int16_t */
#define SCNi32          "li"    /* int32_t */
#define SCNiLEAST16     "hi"    /* int_least16_t */
#define SCNiLEAST32     "li"    /* int_least32_t */
#define SCNiFAST8       "hi"    /* int_fast8_t */
#define SCNiFAST16      "hi"    /* int_fast16_t */
#define SCNiFAST32      "li"    /* int_fast32_t */
#define SCNiMAX         "li"    /* intmax_t */
#define SCNiPTR         "li"    /* intptr_t */

/* fscanf macros for unsigned integers */

#define SCNo16          "ho"    /* uint16_t */
#define SCNo32          "lo"    /* uint32_t */
#define SCNoLEAST16     "ho"    /* uint_least16_t */
#define SCNoLEAST32     "lo"    /* uint_least32_t */
#define SCNoFAST8       "ho"    /* uint_fast8_t */
#define SCNoFAST16      "ho"    /* uint_fast16_t */
#define SCNoFAST32      "lo"    /* uint_fast32_t */
#define SCNoMAX         "lo"    /* uintmax_t */
#define SCNoPTR         "lo"    /* uintptr_t */

#define SCNu16          "hu"    /* uint16_t */
#define SCNu32          "lu"    /* uint32_t */
#define SCNuLEAST16     "hu"    /* uint_least16_t */
#define SCNuLEAST32     "lu"    /* uint_least32_t */
#define SCNuFAST8       "hu"    /* uint_fast8_t */
#define SCNuFAST16      "hu"    /* uint_fast16_t */
#define SCNuFAST32      "lu"    /* uint_fast32_t */
#define SCNuMAX         "lu"    /* uintmax_t */
#define SCNuPTR         "lu"    /* uintptr_t */

#define SCNx16          "hx"    /* uint16_t */
#define SCNx32          "lx"    /* uint32_t */
#define SCNxLEAST16     "hx"    /* uint_least16_t */
#define SCNxLEAST32     "lx"    /* uint_least32_t */
#define SCNxFAST8       "hx"    /* uint_fast8_t */
#define SCNxFAST16      "hx"    /* uint_fast16_t */
#define SCNxFAST32      "lx"    /* uint_fast32_t */
#define SCNxMAX         "lx"    /* uintmax_t */
#define SCNxPTR         "lx"    /* uintptr_t */

/*
 * The C99 and C11 standards require the following functions and the
 * type imaxdiv_t to be declared here, but they are not currently supported.
 * 
 * intmax_t imaxabs(intmax_t j);
 * imaxdiv_t imaxdiv(intmax_t numer, intmax_t denom);
 * intmax_t strtoimax(const char * restrict nptr,
 *         char ** restrict endptr, int base);
 * uintmax_t strtoumax(const char * restrict nptr,
 *         char ** restrict endptr, int base);
 * intmax_t wcstoimax(const wchar_t * restrict nptr,
 *         wchar_t ** restrict endptr, int base);
 * uintmax_t wcstoumax(const wchar_t * restrict nptr,
 *         wchar_t ** restrict endptr, int base);
 */

#endif
