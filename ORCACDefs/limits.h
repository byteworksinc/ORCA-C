/****************************************************************
*
*  limits.h - limits on the size of numbers
*
*  April 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#ifndef __limits__
#define __limits__

#define CHAR_BIT        8
#define CHAR_MAX        255
#define CHAR_MIN        0
#define SHRT_MAX        32767
#define SHRT_MIN        (-32767-1)
#define INT_MAX         32767
#define INT_MIN         (-32767-1)
#define LONG_MAX        2147483647
#define LONG_MIN        (-2147483647-1)
#define MB_LEN_MAX      1
#define SCHAR_MAX       127
#define SCHAR_MIN       (-128)
#define UCHAR_MAX       255
#define UINT_MAX        65535u
#define ULONG_MAX       4294967295u
#define USHRT_MAX       65535u
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
#define LLONG_MIN       (-9223372036854775807-1)
#define LLONG_MAX       9223372036854775807
#define ULLONG_MAX      18446744073709551615u
#endif
#if !defined(__KeepNamespacePure__) || __STDC_VERSION__ >= 202311L
#define BOOL_MAX        1
#define BOOL_WIDTH      1
#define CHAR_WIDTH      8
#define SCHAR_WIDTH     8
#define UCHAR_WIDTH     8
#define SHRT_WIDTH      16
#define USHRT_WIDTH     16
#define INT_WIDTH       16
#define UINT_WIDTH      16
#define LONG_WIDTH      32
#define ULONG_WIDTH     32
#define LLONG_WIDTH     64
#define ULLONG_WIDTH    64
#define BITINT_MAXWIDTH 64
#endif

#endif
