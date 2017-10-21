/* Conformance Test 19.1.0.1:  Verification of abs, fabs, labs functions */

#include <math.h>
#include <stdlib.h>

main ()
  {
   double d1 = -9.0;
   int    i  = -8;
   long   L  = -32767;


   d1 = fabs (1.0 + d1);
   if (fabs(d1 - 8.0) > 0.00001)
       goto Fail;

   i = abs (2 + i);
   if (i != 6)
       goto Fail;

   L = labs (5 + L);
   if (L != 32762)
       goto Fail;

   printf ("Passed Conformance Test 19.1.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 19.1.0.1\n");
  }
