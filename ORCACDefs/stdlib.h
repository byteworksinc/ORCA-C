/****************************************************************
*
*  stdlib.h - standard library functions
*
*  February 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#ifndef __stdlib__
#define __stdlib__

#ifndef NULL
#define NULL (void *) 0L
#endif

#ifndef __size_t__
#define __size_t__ 1
typedef unsigned long size_t;
#endif

#define RAND_MAX        32767
#define EXIT_FAILURE    (-1)
#define EXIT_SUCCESS    0
#define MB_CUR_MAX      1UL

typedef struct {int quot,rem;} div_t;
typedef struct {long quot,rem;} ldiv_t;
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
typedef struct {long long quot,rem;} lldiv_t;
#endif

#ifndef __KeepNamespacePure__
   #define clalloc(x,y)    calloc((x),(y))
   #define cfree(x)        free(x)
   #define mlalloc(x)      malloc(x)
   #define relalloc(x,y)   realloc((x),(y))
#endif

int             abs(int);
void            abort(void);
void           *aligned_alloc(size_t, size_t);
int             atexit(void (*__func)(void));
int             at_quick_exit(void (*__func)(void));
double          atof(const char *);
int             atoi(const char *);
long            atol(const char *);
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
long long       atoll(const char *);
#endif
void           *bsearch(const void *, const void *, size_t, size_t, int (*__compar)(const void *, const void *));
void           *calloc(size_t, size_t);
div_t           div(int, int);
void            exit(int);
void            _exit(int);
void            _Exit(int);
void            free(void *);
char           *getenv(const char *);
long            labs(long);
ldiv_t          ldiv(long, long);
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
long long       llabs(long long);
lldiv_t         lldiv(long long, long long);
#endif
void           *malloc(size_t);
int             mblen(const char *, size_t);
void            qsort(void *, size_t, size_t, int (*__compar)(const void *, const void *));
void            quick_exit(int);
int             rand(void);
void           *realloc(void *, size_t);
void            srand(unsigned);
double          strtod(const char *, char **);
float           strtof(const char *, char **);
long double     strtold(const char *, char **);
long            strtol(const char *, char **, int);
unsigned long   strtoul(const char *, char **, int);
#if defined(__ORCAC_HAS_LONG_LONG__) || __STDC_VERSION__ >= 199901L
long long       strtoll(const char * restrict, char ** restrict, int);
unsigned long long strtoull(const char * restrict, char ** restrict, int);
#endif
int             system(const char *);

#endif
