/* Separately compiled file containing functions called from main program in */
/* the file spc4.3.1.1.cc.                                                   */

#include <ctype.h>

int I1 (char ch)
  {
   if (islower (ch))
       return toupper (ch);
  }

/*****************************************************************************/

#include <math.h>

double D1 (float f)
  {
   return floor (f);
  }
