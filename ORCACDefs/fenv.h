/****************************************************************
*
*  fenv.h - floating-point environment access
*
*  February 2021
*  Stephen Heumann
*
****************************************************************/

#ifndef __fenv__
#define __fenv__

typedef unsigned short fenv_t;
typedef unsigned short fexcept_t;

/* Floating-point exceptions */
#define FE_INVALID    0x01
#define FE_UNDERFLOW  0x02
#define FE_OVERFLOW   0x04
#define FE_DIVBYZERO  0x08
#define FE_INEXACT    0x10
#define FE_ALL_EXCEPT 0x1F

/* Rounding directions */
#define FE_DOWNWARD   0x80
#define FE_TONEAREST  0x00
#define FE_TOWARDZERO 0xC0
#define FE_UPWARD     0x40

extern const fenv_t __FE_DFL_ENV;
#define FE_DFL_ENV (&__FE_DFL_ENV)

int feclearexcept(int);
int fegetexceptflag(fexcept_t *, int);
int feraiseexcept(int);
int fesetexceptflag(const fexcept_t *, int);
int fetestexcept(int);
int fegetround(void);
int fesetround(int);
int fegetenv(fenv_t *);
int feholdexcept(fenv_t *);
int fesetenv(const fenv_t *);
int feupdateenv(const fenv_t *);

#endif
