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

#if !defined(__KeepNamespacePure__) || __STDC_VERSION__ >= 202311L
#ifndef NDEBUG
#ifndef __GNO__
#define assert(...) (__VA_ARGS__) ? ((void) sizeof(__assert_arg_check(__VA_ARGS__))) : (__assert2(__FILE__, __LINE__, __func__, #__VA_ARGS__))
#else
#define assert(...) (__VA_ARGS__) ? ((void) sizeof(__assert_arg_check(__VA_ARGS__))) : (__assert(__FILE__, __LINE__, #__VA_ARGS__))
#endif
#else
#define assert(...) ((void)0)
#endif
#else
#ifndef NDEBUG
#ifndef __GNO__
#define assert(expression) (expression) ? ((void) 0) : (__assert2(__FILE__, __LINE__, __func__, #expression))
#else
#define assert(expression) (expression) ? ((void) 0) : (__assert(__FILE__, __LINE__, #expression))
#endif
#else
#define assert(expression)  ((void)0)
#endif
#endif

#ifndef __assert__
#define __assert__

char __assert_arg_check(_Bool); /* not an actual function */
extern void __assert(const char *, unsigned, const char *);
extern void __assert2(const char *, unsigned, const char *, const char *);

#define static_assert _Static_assert

#endif
