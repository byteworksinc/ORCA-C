/****************************************************************
*
*  stdbool.h - boolean type and values
*
****************************************************************/

#ifndef __stdbool__
#define __stdbool__

#if __STDC_VERSION__ < 202311L
#define bool _Bool
#define true 1
#define false 0
#endif

#define __bool_true_false_are_defined 1

#endif
