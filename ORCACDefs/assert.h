/****************************************************************
*
*  assert.h - debugging facilities
*
*  February 1989
*  Mike Westerfield
*
*  Copyright 1989,1990, 1996
*  Byte Works, Inc.
*
****************************************************************/

#ifdef assert
#undef assert
#endif

#ifndef NDEBUG
#ifndef __GNO__
#define assert(expression) (expression) ? ((void) 0) : (__assert2(__FILE__, __LINE__, __func__, #expression))
#else
#define assert(expression) (expression) ? ((void) 0) : (__assert(__FILE__, __LINE__, #expression))
#endif
#else
#define assert(expression)  ((void)0)
#endif

#ifndef __assert__
#define __assert__

extern void __assert(const char *, unsigned, const char *);
extern void __assert2(const char *, unsigned, const char *, const char *);

#define static_assert _Static_assert

#endif
