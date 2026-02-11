/****************************************************************
*
*  stddef.h - Standard Language Additions
*
*  February 1989
*  Mike Westerfield
*
*  Copyright 1989, 1993
*  Byte Works, Inc.
*
****************************************************************/

#ifndef __stddef__
#define __stddef__

#ifndef NULL
#define NULL  (void *) 0L
#endif

typedef long ptrdiff_t;

#ifndef __size_t__
#define __size_t__ 1
typedef unsigned long size_t;
#endif

typedef long max_align_t;

typedef unsigned short wchar_t;

#if __STDC_VERSION__ >= 202311L
typedef typeof_unqual(nullptr) nullptr_t;
#endif

#define offsetof(type,member) ((size_t) (&(((type *)0L)->member)))

#if !defined(__KeepNamespacePure__) || __STDC_VERSION__ >= 202311L
#define unreachable() ((void)0)
#endif

#endif
