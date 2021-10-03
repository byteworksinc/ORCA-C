/****************************************************************
*
*  uchar.h - Unicode utilities
*
*  October 2021
*  Stephen Heumann
*
****************************************************************/

#ifndef __uchar__
#define __uchar__

typedef unsigned long mbstate_t;

#ifndef __size_t__
#define __size_t__ 1
typedef unsigned long size_t;
#endif

typedef unsigned short char16_t;
typedef unsigned long char32_t;

size_t  c16rtomb(char *, char16_t, mbstate_t *);
size_t  c32rtomb(char *, char32_t, mbstate_t *);
size_t  mbrtoc16(char16_t *, const char *, size_t, mbstate_t *);
size_t  mbrtoc32(char32_t *, const char *, size_t, mbstate_t *);

#endif
