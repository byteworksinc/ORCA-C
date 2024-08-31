/****************************************************************
*
*  stdarg.h - variable length parameter list handling
*
*  February 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
*****************************************************************
*
*  Modified July 1994
*
*  Thanks to Doug Gwyn for the new va_start & va_arg declarations.
*
*****************************************************************
*
*  Modified October 2021 for better standards conformance.
*  This version will only work with ORCA/C 2.2.0 B6 or later.
*
****************************************************************/

#ifndef __stdarg__
#define __stdarg__

#ifndef __va_list__
#define __va_list__
typedef char *__va_list[2];
#endif

typedef __va_list va_list;
#define va_end(ap) __record_va_info(ap)
#if __STDC_VERSION__ >= 202311L
#define va_start(ap,...) ((void) ((ap)[0] = (char *)__orcac_va_info[1], (ap)[1] = (char *)&__orcac_va_info))
#else
#define va_start(ap,LastFixedParm) ((void) ((ap)[0] = (char *)__orcac_va_info[1], (ap)[1] = (char *)&__orcac_va_info))
#endif
#define va_arg(ap,type) _Generic(*(type *)0, \
        double: (type)((long double *)((ap)[0] += sizeof(long double)))[-1], \
        default: ((type *)((ap)[0] += sizeof(type)))[-1])
#define va_copy(dest,src) ((void)((dest)[0]=(src)[0],(dest)[1]=(src)[1]))

void __record_va_info(va_list);

#endif
