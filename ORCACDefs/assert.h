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
#define assert(expression) (expression) ? ((void) 0) : (__assert(__FILE__, __LINE__, #expression))
#else
#define assert(expression)  ((void) 0)
#endif

#ifndef __assert__
#define __assert__

extern void __assert(char *, int, char *);

#define static_assert _Static_assert

#endif
